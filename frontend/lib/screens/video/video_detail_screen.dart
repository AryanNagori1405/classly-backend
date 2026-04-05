import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/video_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

/// Video detail screen with:
/// - Video playback placeholder (video_player integration point)
/// - Timestamp doubts system
/// - FAQ section
/// - Notes/documents
/// - Bookmark & download actions
class VideoDetailScreen extends StatefulWidget {
  final Video video;

  const VideoDetailScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _doubtController = TextEditingController();
  final _timestampController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isLoadingTimestamps = false;
  bool _isLoadingFAQ = false;
  List<Map<String, dynamic>> _timestamps = [];
  List<Map<String, dynamic>> _faqItems = [];
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTimestamps();
    _loadFAQ();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _doubtController.dispose();
    _timestampController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  /// Parse the video id safely. Returns null if the id is not a valid integer.
  int? get _videoId => int.tryParse(widget.video.id);

  Future<void> _loadTimestamps() async {
    final videoId = _videoId;
    if (videoId == null) return;
    setState(() => _isLoadingTimestamps = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService();
      final result = await api.getTimestamps(
        token: auth.token!,
        videoId: videoId,
      );
      setState(() {
        _timestamps = List<Map<String, dynamic>>.from(
            result['timestamps'] as List? ?? []);
      });
    } catch (_) {}
    setState(() => _isLoadingTimestamps = false);
  }

  Future<void> _loadFAQ() async {
    final videoId = _videoId;
    if (videoId == null) return;
    setState(() => _isLoadingFAQ = true);
    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService();
      final result = await api.getTimestampFAQ(
        token: auth.token!,
        videoId: videoId,
      );
      setState(() {
        _faqItems =
            List<Map<String, dynamic>>.from(result['faq'] as List? ?? []);
      });
    } catch (_) {}
    setState(() => _isLoadingFAQ = false);
  }

  Future<void> _addDoubt() async {
    final ts = _timestampController.text.trim();
    final q = _doubtController.text.trim();
    if (ts.isEmpty || q.isEmpty) {
      _showSnack('Please enter both timestamp and your doubt');
      return;
    }
    final videoId = _videoId;
    if (videoId == null) {
      _showSnack('Invalid video. Cannot add doubt.');
      return;
    }
    // Validate HH:MM:SS or MM:SS
    final tsRegex = RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$');
    if (!tsRegex.hasMatch(ts)) {
      _showSnack('Use HH:MM:SS or MM:SS format for timestamp');
      return;
    }
    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService();
      await api.addTimestampDoubt(
        token: auth.token!,
        videoId: videoId,
        timestampValue: ts,
        questionText: q,
      );
      _timestampController.clear();
      _doubtController.clear();
      Navigator.of(context).pop();
      _showSnack('Doubt added successfully!');
      _loadTimestamps();
    } catch (e) {
      _showSnack('Failed to add doubt: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    final videoId = _videoId;
    if (videoId == null) return;
    final auth = context.read<AuthProvider>();
    final api = ApiService();
    try {
      if (_isBookmarked) {
        await api.removeBookmark(token: auth.token!, videoId: videoId);
      } else {
        await api.addBookmark(token: auth.token!, videoId: videoId);
      }
      setState(() => _isBookmarked = !_isBookmarked);
      _showSnack(_isBookmarked ? 'Bookmarked!' : 'Bookmark removed');
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  Future<void> _downloadVideo() async {
    final videoId = _videoId;
    if (videoId == null) return;
    final auth = context.read<AuthProvider>();
    final api = ApiService();
    try {
      final result = await api.downloadVideo(
        token: auth.token!,
        videoId: videoId,
      );
      _showSnack('Download link: ${result['download_link'] ?? 'Ready'}');
    } catch (e) {
      _showSnack('Failed to download: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showAddDoubtSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Timestamp Doubt',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900])),
            const SizedBox(height: 16),
            TextField(
              controller: _timestampController,
              decoration: InputDecoration(
                labelText: 'Timestamp (e.g. 12:34 or 01:23:45)',
                prefixIcon: const Icon(Icons.timer_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _doubtController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Your question / doubt',
                prefixIcon: const Icon(Icons.help_outline),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addDoubt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Doubt',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final auth = context.watch<AuthProvider>();
    final isTeacher = auth.user?.role == 'teacher';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(video.title,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked
                  ? AppColors.primaryColor
                  : Colors.grey[700],
            ),
            onPressed: _toggleBookmark,
            tooltip: 'Bookmark',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            color: Colors.grey[700],
            onPressed: _downloadVideo,
            tooltip: 'Download',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Video player area ──────────────────────────────────────────────
          Container(
            height: 220,
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (video.thumbnailUrl.isNotEmpty)
                  Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox.shrink(),
                  ),
                Container(color: Colors.black54),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Icon(Icons.play_arrow_rounded,
                      color: AppColors.primaryColor, size: 40),
                ),
                // Expiry badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: video.daysRemaining <= 1
                          ? Colors.red
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${video.daysRemaining}d left',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Metadata ────────────────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text('${video.views} views',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule_outlined,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text('${video.duration ~/ 60}min',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(width: 16),
                    Icon(Icons.category_outlined,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(video.subject,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500]),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tabs ────────────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'Doubts'),
              Tab(text: 'FAQ'),
              Tab(text: 'Notes'),
            ],
          ),

          // ── Tab views ───────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── DOUBTS TAB ────────────────────────────────────────────────
                _DoubtsTab(
                  timestamps: _timestamps,
                  isLoading: _isLoadingTimestamps,
                  isTeacher: isTeacher,
                  token: auth.token ?? '',
                  onRefresh: _loadTimestamps,
                ),

                // ── FAQ TAB ───────────────────────────────────────────────────
                _FAQTab(
                  faqItems: _faqItems,
                  isLoading: _isLoadingFAQ,
                ),

                // ── NOTES TAB ─────────────────────────────────────────────────
                _NotesTab(
                  videoId: int.tryParse(video.id) ?? 0,
                  token: auth.token ?? '',
                  isTeacher: isTeacher,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDoubtSheet,
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        label: const Text('Ask Doubt',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ── Doubts tab ───────────────────────────────────────────────────────────────
class _DoubtsTab extends StatelessWidget {
  final List<Map<String, dynamic>> timestamps;
  final bool isLoading;
  final bool isTeacher;
  final String token;
  final VoidCallback onRefresh;

  const _DoubtsTab({
    required this.timestamps,
    required this.isLoading,
    required this.isTeacher,
    required this.token,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (timestamps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No doubts yet. Be the first to ask!',
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: timestamps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final ts = timestamps[i];
          return _TimestampCard(
            timestamp: ts,
            isTeacher: isTeacher,
            token: token,
            onRefresh: onRefresh,
          );
        },
      ),
    );
  }
}

class _TimestampCard extends StatelessWidget {
  final Map<String, dynamic> timestamp;
  final bool isTeacher;
  final String token;
  final VoidCallback onRefresh;

  const _TimestampCard({
    required this.timestamp,
    required this.isTeacher,
    required this.token,
    required this.onRefresh,
  });

  Future<void> _resolve(BuildContext context) async {
    try {
      await ApiService().resolveDoubt(
        token: token,
        timestampId: timestamp['id'] as int,
      );
      onRefresh();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = timestamp['is_resolved'] as bool? ?? false;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isResolved
            ? Colors.green.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isResolved
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timestamp['timestamp_value'] as String? ?? '',
                  style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              if (isResolved)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Resolved',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              const Spacer(),
              Text(
                timestamp['student_name'] as String? ?? 'Student',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            timestamp['question_text'] as String? ?? '',
            style: const TextStyle(fontSize: 14),
          ),
          if (isTeacher && !isResolved) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _resolve(context),
                icon: const Icon(Icons.check_circle_outline,
                    size: 16, color: Colors.green),
                label: const Text('Mark Resolved',
                    style: TextStyle(color: Colors.green, fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── FAQ tab ──────────────────────────────────────────────────────────────────
class _FAQTab extends StatelessWidget {
  final List<Map<String, dynamic>> faqItems;
  final bool isLoading;

  const _FAQTab({required this.faqItems, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (faqItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('FAQ will appear once doubts are resolved',
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: faqItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = faqItems[i];
        return ExpansionTile(
          title: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['timestamp_value'] as String? ?? '',
                  style: TextStyle(
                      color: AppColors.primaryColor, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['question_text'] as String? ?? '',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          children: [
            ...List<String>.from(item['answers'] as List? ?? [])
                .map((a) => ListTile(
                      leading: const Icon(Icons.chat_bubble_outline,
                          size: 16, color: Colors.grey),
                      title: Text(a,
                          style: const TextStyle(fontSize: 13)),
                    )),
          ],
        );
      },
    );
  }
}

// ── Notes tab ────────────────────────────────────────────────────────────────
class _NotesTab extends StatefulWidget {
  final int videoId;
  final String token;
  final bool isTeacher;

  const _NotesTab({
    required this.videoId,
    required this.token,
    required this.isTeacher,
  });

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final result = await ApiService().getVideoNotes(
        token: widget.token,
        videoId: widget.videoId,
      );
      setState(() {
        _notes = List<Map<String, dynamic>>.from(
            result['notes'] as List? ?? []);
      });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined,
                size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No notes attached yet',
                style:
                    TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final note = _notes[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                AppColors.primaryColor.withOpacity(0.1),
            child: Icon(Icons.description_outlined,
                color: AppColors.primaryColor),
          ),
          title: Text(note['note_title'] as String? ?? 'Note',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
            (note['file_type'] as String? ?? 'pdf').toUpperCase(),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Opening: ${note['file_url'] as String? ?? ''}'),
              ));
            },
          ),
        );
      },
    );
  }
}
