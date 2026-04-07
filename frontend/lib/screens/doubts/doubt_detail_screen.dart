import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class DoubtDetailScreen extends StatefulWidget {
  final String doubtId;
  final String videoTitle;
  final String timestamp;
  /// Optionally pass preloaded comments so the screen can display them immediately.
  final List<Map<String, dynamic>> initialComments;

  const DoubtDetailScreen({
    Key? key,
    required this.doubtId,
    required this.videoTitle,
    required this.timestamp,
    this.initialComments = const [],
  }) : super(key: key);

  @override
  State<DoubtDetailScreen> createState() => _DoubtDetailScreenState();
}

class _DoubtDetailScreenState extends State<DoubtDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _replyController = TextEditingController();

  List<Map<String, dynamic>> _comments = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _comments = List<Map<String, dynamic>>.from(widget.initialComments);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  int? get _timestampId => int.tryParse(widget.doubtId);  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _timestampId == null) return;
    setState(() => _isSubmitting = true);
    try {
      final token = context.read<AuthProvider>().token!;
      await _apiService.addComment(
        token: token,
        timestampId: _timestampId!,
        commentText: text,
      );
      _replyController.clear();
      // Optimistically add the comment to the local list
      final user = context.read<AuthProvider>().user;
      setState(() {
        _comments.add({
          'comment_text': text,
          'author_name': user?.name ?? 'You',
          'is_anonymous': false,
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reply: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resolveDoubt() async {
    final id = _timestampId;
    if (id == null) return;
    try {
      final token = context.read<AuthProvider>().token!;
      await _apiService.resolveDoubt(token: token, timestampId: id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doubt marked as resolved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  bool get _isTeacher =>
      context.read<AuthProvider>().user?.role == 'teacher';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Doubt Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isTeacher)
            TextButton(
              onPressed: _resolveDoubt,
              child: const Text(
                'Resolve',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildComments()),
          _buildReplyBox(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.timestamp,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.videoTitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    if (_comments.isEmpty) {
      return const Center(
        child: Text(
          'No replies yet. Start the discussion!',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final c = _comments[index];
        return _CommentTile(
          authorName: c['author_name'] as String? ?? 'Anonymous',
          content: c['comment_text'] as String? ?? '',
          isAnonymous: c['is_anonymous'] as bool? ?? false,
        );
      },
    );
  }

  Widget _buildReplyBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: InputDecoration(
                hintText: 'Write a reply...',
                hintStyle:
                    const TextStyle(color: AppColors.textLight, fontSize: 14),
                filled: true,
                fillColor: AppColors.backgroundColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _isSubmitting
              ? const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : IconButton(
                  onPressed: _submitReply,
                  icon: const Icon(Icons.send_rounded,
                      color: AppColors.primaryColor),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String authorName;
  final String content;
  final bool isAnonymous;

  const _CommentTile({
    required this.authorName,
    required this.content,
    required this.isAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAnonymous ? 'Anonymous' : authorName,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
