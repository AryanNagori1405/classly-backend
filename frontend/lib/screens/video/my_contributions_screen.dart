import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import 'upload_contribution_screen.dart';

class MyContributionsScreen extends StatefulWidget {
  const MyContributionsScreen({Key? key}) : super(key: key);

  @override
  State<MyContributionsScreen> createState() => _MyContributionsScreenState();
}

class _MyContributionsScreenState extends State<MyContributionsScreen> {
  List<dynamic> _contributions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContributions();
  }

  Future<void> _loadContributions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token!;
      final result = await ApiService().getMyContributions(token: token);
      setState(() {
        _contributions = (result['contributions'] as List?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteContribution(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contribution'),
        content: const Text('Are you sure you want to delete this contribution?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.errorColor))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = context.read<AuthProvider>().token!;
      await ApiService().deleteContribution(token: token, contributionId: id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contribution deleted')),
      );
      _loadContributions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('My Contributions',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContributions,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const UploadContributionScreen()),
          );
          if (result == true) _loadContributions();
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Upload',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.errorColor),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContributions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_contributions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file_outlined,
                size: 72, color: AppColors.textLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No contributions yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted)),
            const SizedBox(height: 8),
            const Text('Share your knowledge with peers!',
                style: TextStyle(color: AppColors.textLight)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContributions,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _contributions.length,
        itemBuilder: (_, i) => _buildContributionCard(_contributions[i]),
      ),
    );
  }

  Widget _buildContributionCard(Map<String, dynamic> c) {
    final isApproved = c['is_approved'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _fileTypeIcon(c['file_type'] ?? 'video'),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    c['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? AppColors.successColor.withOpacity(0.1)
                        : AppColors.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isApproved ? 'Approved' : 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isApproved
                          ? AppColors.successColor
                          : AppColors.warningColor,
                    ),
                  ),
                ),
              ],
            ),
            if (c['description'] != null &&
                (c['description'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                c['description'],
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (c['related_video_title'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.link, size: 13, color: AppColors.primaryColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Linked: ${c['related_video_title']}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primaryColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _statChip(Icons.remove_red_eye_outlined,
                    '${c['views_count'] ?? 0}'),
                const SizedBox(width: 12),
                _statChip(Icons.thumb_up_outlined, '${c['upvotes'] ?? 0}'),
                const Spacer(),
                IconButton(
                  onPressed: () => _deleteContribution(c['id'] as int),
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.errorColor, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label) => Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      );

  Widget _fileTypeIcon(String type) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'ppt':
      case 'pptx':
        icon = Icons.slideshow;
        color = Colors.orange;
        break;
      default:
        icon = Icons.play_circle_fill;
        color = AppColors.primaryColor;
    }
    return Icon(icon, color: color, size: 22);
  }
}
