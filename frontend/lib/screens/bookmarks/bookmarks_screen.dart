import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/video_model.dart';
import '../video/video_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      final result =
          await ApiService().getBookmarks(token: auth.token ?? '');
      setState(() {
        _bookmarks = List<Map<String, dynamic>>.from(
            result['bookmarks'] as List? ?? []);
      });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _removeBookmark(int videoId) async {
    try {
      final auth = context.read<AuthProvider>();
      await ApiService()
          .removeBookmark(token: auth.token ?? '', videoId: videoId);
      setState(() {
        _bookmarks.removeWhere((b) => b['id'] == videoId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark removed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Bookmarks',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border,
                          size: 70, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No bookmarks yet',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      Text('Bookmark lectures to find them quickly later',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[500])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookmarks,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookmarks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final b = _bookmarks[i];
                      return _BookmarkCard(
                        bookmark: b,
                        onRemove: () => _removeBookmark(b['id'] as int),
                        onTap: () {
                          final video = Video(
                            id: b['id'].toString(),
                            title: b['title'] as String? ?? '',
                            description: b['description'] as String? ?? '',
                            uploadedBy:
                                b['teacher_name'] as String? ?? '',
                            videoUrl: b['file_url'] as String? ?? '',
                            thumbnailUrl:
                                b['thumbnail_url'] as String? ?? '',
                            subject:
                                b['subject_category'] as String? ?? '',
                            category: '',
                            duration: b['duration'] as int? ?? 0,
                            createdAt: DateTime.tryParse(
                                    b['created_at'] as String? ?? '') ??
                                DateTime.now(),
                            views: b['views_count'] as int? ?? 0,
                          );
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) =>
                                  VideoDetailScreen(video: video)));
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Map<String, dynamic> bookmark;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _BookmarkCard({
    required this.bookmark,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final expiresAt =
        DateTime.tryParse(bookmark['expires_at'] as String? ?? '');
    final daysLeft =
        expiresAt?.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80,
                height: 60,
                color: AppColors.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.play_circle_fill_rounded,
                    color: AppColors.primaryColor, size: 36),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bookmark['title'] as String? ?? 'Video',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(bookmark['teacher_name'] as String? ?? '',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500])),
                  if (daysLeft != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      daysLeft <= 0
                          ? 'Expired'
                          : '$daysLeft day${daysLeft == 1 ? '' : 's'} left',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              daysLeft <= 1 ? Colors.red : Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_remove_outlined,
                  color: Colors.grey),
              onPressed: onRemove,
              tooltip: 'Remove bookmark',
            ),
          ],
        ),
      ),
    );
  }
}
