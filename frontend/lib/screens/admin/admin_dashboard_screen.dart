import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

/// Admin dashboard screen.
/// Shows:
/// - All anonymous feedback WITH real sender details
/// - User management (suspend / activate)
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _feedback = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoadingFeedback = true;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeedback();
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedback() async {
    setState(() => _isLoadingFeedback = true);
    try {
      final auth = context.read<AuthProvider>();
      final result =
          await ApiService().getAllFeedback(token: auth.token ?? '');
      setState(() {
        _feedback = List<Map<String, dynamic>>.from(
            result['feedback'] as List? ?? []);
      });
    } catch (_) {}
    setState(() => _isLoadingFeedback = false);
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final auth = context.read<AuthProvider>();
      final result =
          await ApiService().adminGetUsers(token: auth.token ?? '');
      setState(() {
        _users = List<Map<String, dynamic>>.from(
            result['users'] as List? ?? []);
      });
    } catch (_) {}
    setState(() => _isLoadingUsers = false);
  }

  Future<void> _toggleUserStatus(
      int userId, bool currentlyActive) async {
    try {
      final auth = context.read<AuthProvider>();
      await ApiService().adminUpdateUser(
        token: auth.token ?? '',
        userId: userId,
        isActive: !currentlyActive,
        reason: currentlyActive ? 'Suspended by admin' : 'Activated by admin',
      );
      _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.user?.role != 'admin') {
      return const Scaffold(
        body: Center(child: Text('Admin access required')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Admin Dashboard',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(
                icon: Icon(Icons.feedback_outlined),
                text: 'Feedback'),
            Tab(
                icon: Icon(Icons.people_outline),
                text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── FEEDBACK TAB ───────────────────────────────────────────────────
          _isLoadingFeedback
              ? const Center(child: CircularProgressIndicator())
              : _feedback.isEmpty
                  ? Center(
                      child: Text('No feedback found',
                          style: TextStyle(color: Colors.grey[500])))
                  : RefreshIndicator(
                      onRefresh: _loadFeedback,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _feedback.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _FeedbackAdminCard(feedback: _feedback[i]),
                      ),
                    ),

          // ── USERS TAB ──────────────────────────────────────────────────────
          _isLoadingUsers
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                  ? Center(
                      child: Text('No users found',
                          style: TextStyle(color: Colors.grey[500])))
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final u = _users[i];
                          final isActive =
                              u['is_active'] as bool? ?? true;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primaryColor.withOpacity(0.1),
                              child: Text(
                                (u['name'] as String? ?? '?')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(u['name'] as String? ?? 'User'),
                            subtitle: Text(
                                '${u['role'] as String? ?? ''} • ${u['reg_no'] ?? ''}'),
                            trailing: Switch(
                              value: isActive,
                              activeColor: Colors.green,
                              onChanged: (_) => _toggleUserStatus(
                                  u['id'] as int, isActive),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

class _FeedbackAdminCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  const _FeedbackAdminCard({required this.feedback});

  static const _categoryColors = {
    'suggestion': Colors.blue,
    'improvement': Colors.orange,
    'bug': Colors.red,
    'other': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final category = feedback['category'] as String? ?? 'other';
    final color = _categoryColors[category] ?? Colors.grey;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(category.toUpperCase(),
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              const Icon(Icons.admin_panel_settings_outlined,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Admin view',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 10),
          Text(feedback['message'] as String? ?? '',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To: ${feedback['teacher_name'] as String? ?? '—'}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'From: ${feedback['sender_name'] as String? ?? '—'} '
                      '(${feedback['sender_reg_no'] ?? ''})',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold),
                    ),
                    if (feedback['ip_address'] != null)
                      Text('IP: ${feedback['ip_address']}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
