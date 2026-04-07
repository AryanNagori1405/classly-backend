import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/animations/fade_animation.dart';

class FeedbackDashboardScreen extends StatefulWidget {
  const FeedbackDashboardScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackDashboardScreen> createState() => _FeedbackDashboardScreenState();
}

class _FeedbackDashboardScreenState extends State<FeedbackDashboardScreen> {
  bool _isLoading = false;
  List<dynamic> _feedbackList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final data = await ApiService().getReceivedFeedback(token: token);
      if (!mounted) return;
      setState(() {
        _feedbackList = data['feedback'] as List? ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _showRespondDialog(Map<String, dynamic> feedback) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Respond to Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                feedback['message'] ?? '',
                style: const TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type your response...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _submitResponse(feedback['id'] as int, controller.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitResponse(int feedbackId, String response) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      await ApiService().respondToFeedback(
          token: token, feedbackId: feedbackId, response: response);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✓ Response sent!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _loadFeedback();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'suggestion':
        return const Color(0xFF06B6D4);
      case 'complaint':
        return const Color(0xFFEF4444);
      case 'praise':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Feedback Dashboard'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeedback,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadFeedback,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _feedbackList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.feedback_outlined,
                              color: Colors.grey.shade400, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No feedback received yet',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Student feedback will appear here',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingLarge),
                      itemCount: _feedbackList.length,
                      itemBuilder: (context, index) {
                        return _buildFeedbackCard(index);
                      },
                    ),
    );
  }

  Widget _buildFeedbackCard(int index) {
    final item = _feedbackList[index] as Map<String, dynamic>;
    final category = item['category'] ?? 'general';
    final message = item['message'] ?? '';
    final hasResponse = item['response'] != null && item['response'].toString().isNotEmpty;
    final color = _categoryColor(category);

    return FadeAnimation(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          side: BorderSide(color: color.withOpacity(0.3), width: 1.5),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (hasResponse)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 12),
                          const SizedBox(width: 4),
                          const Text(
                            'Responded',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),

              // Response (if exists)
              if (hasResponse) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.reply, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['response'].toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Respond button (only if not yet responded)
              if (!hasResponse) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showRespondDialog(item),
                    icon: const Icon(Icons.reply, size: 18),
                    label: const Text('Respond'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: const BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
