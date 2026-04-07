import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

/// Anonymous feedback screen – students can send suggestions to teachers.
/// The message is anonymous to the teacher; admin can see the real sender.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedCategory = 'suggestion';
  int? _selectedTeacherId;
  List<Map<String, dynamic>> _teachers = [];
  bool _isLoading = false;
  bool _isLoadingTeachers = true;

  final List<Map<String, String>> _categories = [
    {'value': 'suggestion', 'label': 'Suggestion', 'icon': '💡'},
    {'value': 'improvement', 'label': 'Improvement', 'icon': '🚀'},
    {'value': 'bug', 'label': 'Issue / Bug', 'icon': '🐛'},
    {'value': 'other', 'label': 'Other', 'icon': '📝'},
  ];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    try {
      final auth = context.read<AuthProvider>();
      final result =
          await ApiService().getTeachers(token: auth.token ?? '');
      setState(() {
        _teachers = List<Map<String, dynamic>>.from(
            result['teachers'] as List? ?? []);
      });
    } catch (_) {}
    setState(() => _isLoadingTeachers = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeacherId == null) {
      _showSnack('Please select a teacher');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();
      await ApiService().sendFeedback(
        token: auth.token ?? '',
        teacherId: _selectedTeacherId!,
        message: _messageController.text.trim(),
        category: _selectedCategory,
      );
      _messageController.clear();
      setState(() => _selectedTeacherId = null);
      _showSnack('Feedback sent anonymously ✓');
    } catch (e) {
      _showSnack('Failed to send: $e');
    }
    setState(() => _isLoading = false);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text('Anonymous Feedback',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 17,
                fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('🔒', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your identity is protected',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor)),
                          const SizedBox(height: 4),
                          Text(
                            'The teacher cannot see who sent this message. '
                            'Only platform admins have access to sender details for abuse prevention.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Select teacher
              Text('Select Teacher',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800])),
              const SizedBox(height: 8),
              _isLoadingTeachers
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      value: _selectedTeacherId,
                      hint: const Text('Choose a teacher'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _teachers
                          .map((t) => DropdownMenuItem<int>(
                                value: t['id'] as int?,
                                child: Text(
                                    t['name'] as String? ?? 'Unknown'),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedTeacherId = v),
                    ),
              const SizedBox(height: 20),

              // Category chips
              Text('Category',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800])),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat['value'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat['value']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryColor
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryColor
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat['icon']!,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(cat['label']!,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Message
              Text('Your Message',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800])),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                      'Type your suggestion, feedback, or question here...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v == null || v.trim().length < 10
                    ? 'Message must be at least 10 characters'
                    : null,
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Send Anonymously',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
