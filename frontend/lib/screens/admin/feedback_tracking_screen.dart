import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class FeedbackTrackingScreen extends StatefulWidget {
  const FeedbackTrackingScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackTrackingScreen> createState() =>
      _FeedbackTrackingScreenState();
}

class _FeedbackTrackingScreenState extends State<FeedbackTrackingScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _feedbackList = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token!;
      final result = await _apiService.adminGetAllFeedback(token: token);
      setState(() {
        _feedbackList = List<Map<String, dynamic>>.from(
            result['feedback'] as List? ?? []);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Feedback Tracking',
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
                onPressed: _loadFeedback, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_feedbackList.isEmpty) {
      return const Center(
        child: Text('No feedback found.',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return Column(
      children: [
        _buildSummaryBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadFeedback,
            color: AppColors.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _feedbackList.length,
              itemBuilder: (context, i) {
                return _FeedbackTrackingTile(feedback: _feedbackList[i]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.warningColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_feedbackList.length} feedback entries — sender info visible to admins only',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackTrackingTile extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const _FeedbackTrackingTile({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final content =
        feedback['content'] as String? ?? feedback['message'] as String? ?? '';
    final category = feedback['category'] as String? ?? 'other';
    final senderName =
        feedback['sender_name'] as String? ?? feedback['sender'] as String?;
    final senderUid = feedback['sender_uid'] as String?;
    final ipAddress = feedback['ip_address'] as String?;
    final createdAt = feedback['created_at'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.warningColor.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.visibility_outlined,
                    size: 14, color: AppColors.warningColor),
                const SizedBox(width: 6),
                const Text(
                  'Admin View — Sender Info',
                  style: TextStyle(
                    color: AppColors.warningColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _CategoryBadge(category: category),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                if (senderName != null)
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Sender',
                    value: senderName,
                  ),
                if (senderUid != null)
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'UID',
                    value: senderUid,
                  ),
                if (ipAddress != null)
                  _InfoRow(
                    icon: Icons.lan_outlined,
                    label: 'IP Address',
                    value: ipAddress,
                  ),
                if (createdAt.isNotEmpty)
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Submitted',
                    value: createdAt,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.isNotEmpty
            ? category[0].toUpperCase() + category.substring(1)
            : category,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
