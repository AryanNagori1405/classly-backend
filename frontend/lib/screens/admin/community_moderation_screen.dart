import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class CommunityModerationScreen extends StatefulWidget {
  const CommunityModerationScreen({Key? key}) : super(key: key);

  @override
  State<CommunityModerationScreen> createState() =>
      _CommunityModerationScreenState();
}

class _CommunityModerationScreenState
    extends State<CommunityModerationScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _communities = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token!;
      final result = await _apiService.getCommunities(token: token);
      setState(() {
        _communities = List<Map<String, dynamic>>.from(
            result['communities'] as List? ?? []);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirm(int communityId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Community'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCommunity(communityId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCommunity(int communityId) async {
    try {
      final token = context.read<AuthProvider>().token!;
      await _apiService.leaveCommunity(
          token: token, communityId: communityId);
      await _loadCommunities();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community removed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Community Moderation',
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
      ),
      body: _buildBody(),
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
                onPressed: _loadCommunities, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_communities.isEmpty) {
      return const Center(
        child: Text('No communities found.',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return Column(
      children: [
        _buildStatsBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCommunities,
            color: AppColors.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _communities.length,
              itemBuilder: (context, i) {
                final c = _communities[i];
                return _CommunityModerationTile(
                  community: c,
                  onDelete: () => _showDeleteConfirm(
                    c['id'] as int? ?? 0,
                    c['name'] as String? ?? 'Community',
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          _StatChip(
            label: 'Total',
            value: '${_communities.length}',
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 12),
          _StatChip(
            label: 'Private',
            value: '${_communities.where((c) => c['is_private'] == true).length}',
            color: AppColors.warningColor,
          ),
          const SizedBox(width: 12),
          _StatChip(
            label: 'Public',
            value:
                '${_communities.where((c) => c['is_private'] != true).length}',
            color: AppColors.successColor,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CommunityModerationTile extends StatelessWidget {
  final Map<String, dynamic> community;
  final VoidCallback onDelete;

  const _CommunityModerationTile({
    required this.community,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = community['name'] as String? ?? 'Unnamed';
    final description = community['description'] as String? ?? '';
    final memberCount = community['member_count'] as int? ?? 0;
    final isPrivate = community['is_private'] as bool? ?? false;
    final category = community['category'] as String? ?? 'general';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPrivate
                            ? AppColors.warningColor.withOpacity(0.12)
                            : AppColors.successColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPrivate ? 'Private' : 'Public',
                        style: TextStyle(
                          color: isPrivate
                              ? AppColors.warningColor
                              : AppColors.successColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '$memberCount members',
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $category',
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.errorColor, size: 22),
            tooltip: 'Delete community',
          ),
        ],
      ),
    );
  }
}
