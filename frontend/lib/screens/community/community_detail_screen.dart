import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/community/community_post_widget.dart';

class CommunityDetailScreen extends StatefulWidget {
  final String communityId;
  final String communityName;

  const CommunityDetailScreen({
    Key? key,
    required this.communityId,
    required this.communityName,
  }) : super(key: key);

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token!;
      final id = int.tryParse(widget.communityId) ?? 0;
      final result = await _apiService.getCommunityPosts(
        token: token,
        communityId: id,
      );
      setState(() {
        _posts = List<Map<String, dynamic>>.from(result['posts'] as List? ?? []);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _likePost(int postId) async {
    try {
      final token = context.read<AuthProvider>().token!;
      final communityId = int.tryParse(widget.communityId) ?? 0;
      await _apiService.likePost(
        token: token,
        communityId: communityId,
        postId: postId,
      );
      await _loadPosts();
    } catch (_) {}
  }

  Future<void> _createPost(String content) async {
    try {
      final token = context.read<AuthProvider>().token!;
      final id = int.tryParse(widget.communityId) ?? 0;
      await _apiService.createPost(
        token: token,
        communityId: id,
        content: content,
      );
      await _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post: $e')),
      );
    }
  }

  void _showCreatePostDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Post'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write something...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx);
                _createPost(text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.communityName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
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
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.errorColor)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          'No posts yet. Be the first to post!',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadPosts,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final createdAt = post['created_at'] != null
              ? DateTime.tryParse(post['created_at'] as String) ?? DateTime.now()
              : DateTime.now();
          return CommunityPostWidget(
            content: post['content'] as String? ?? '',
            authorName: post['author_name'] as String? ?? 'Anonymous',
            createdAt: createdAt,
            likesCount: post['likes_count'] as int? ?? 0,
            isLiked: post['is_liked'] as bool? ?? false,
            onLike: () => _likePost(post['id'] as int? ?? 0),
          );
        },
      ),
    );
  }
}
