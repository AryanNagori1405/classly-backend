import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class FeedbackAnalyticsScreen extends StatefulWidget {
  const FeedbackAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackAnalyticsScreen> createState() =>
      _FeedbackAnalyticsScreenState();
}

class _FeedbackAnalyticsScreenState extends State<FeedbackAnalyticsScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _feedbackList = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token!;
      final results = await Future.wait([
        _apiService.getReceivedFeedback(token: token),
        _apiService.getFeedbackAnalytics(token: token),
      ]);
      setState(() {
        _feedbackList = List<Map<String, dynamic>>.from(
            results[0]['feedback'] as List? ?? []);
        _analytics = results[1] as Map<String, dynamic>;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int get _respondedCount =>
      _feedbackList.where((f) => f['response'] != null).length;

  String get _responseRate {
    if (_feedbackList.isEmpty) return '0%';
    final rate = (_respondedCount / _feedbackList.length * 100).round();
    return '$rate%';
  }

  Map<String, int> get _categoryBreakdown {
    final map = <String, int>{};
    for (final f in _feedbackList) {
      final cat = f['category'] as String? ?? 'other';
      map[cat] = (map[cat] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Feedback Analytics',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style:
                              const TextStyle(color: AppColors.errorColor)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primaryColor,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryRow(),
                      const SizedBox(height: 16),
                      _buildCategoryBreakdown(),
                      const SizedBox(height: 16),
                      _buildFeedbackList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: '${_feedbackList.length}',
            icon: Icons.feedback_outlined,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Response Rate',
            value: _responseRate,
            icon: Icons.reply_rounded,
            color: AppColors.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Responded',
            value: '$_respondedCount',
            icon: Icons.check_circle_outline,
            color: AppColors.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    final breakdown = _categoryBreakdown;
    if (breakdown.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Breakdown',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ...breakdown.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _CategoryBadge(category: e.key),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _feedbackList.isEmpty
                          ? 0
                          : e.value / _feedbackList.length,
                      backgroundColor: AppColors.borderColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.value}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList() {
    if (_feedbackList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No feedback received yet.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Feedback',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        ..._feedbackList.map((f) => _FeedbackTile(feedback: f)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
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
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const _FeedbackTile({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final category = feedback['category'] as String? ?? 'other';
    final content = feedback['content'] as String? ?? feedback['message'] as String? ?? '';
    final hasResponse = feedback['response'] != null;

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
          Row(
            children: [
              _CategoryBadge(category: category),
              const Spacer(),
              if (hasResponse)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.successColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (hasResponse) ...[
            const Divider(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.reply_rounded,
                    size: 14, color: AppColors.textLight),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    feedback['response'] as String,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
