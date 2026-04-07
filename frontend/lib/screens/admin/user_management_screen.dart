import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;
  String _filterRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token!;
      final result = await _apiService.adminGetUsers(
        token: token,
        role: _filterRole == 'all' ? null : _filterRole,
      );
      setState(() {
        _users =
            List<Map<String, dynamic>>.from(result['users'] as List? ?? []);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserStatus(
      int userId, bool currentlyActive) async {
    try {
      final token = context.read<AuthProvider>().token!;
      await _apiService.adminUpdateUser(
        token: token,
        userId: userId,
        isActive: !currentlyActive,
      );
      await _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              currentlyActive ? 'User suspended' : 'User activated'),
        ),
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
          'User Management',
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
      body: Column(
        children: [
          _buildFilterRow(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    const roles = ['all', 'student', 'teacher', 'admin'];
    return Container(
      height: 48,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: roles.length,
        itemBuilder: (context, i) {
          final r = roles[i];
          final selected = _filterRole == r;
          return GestureDetector(
            onTap: () {
              setState(() => _filterRole = r);
              _loadUsers();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryColor
                    : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryColor
                      : AppColors.borderColor,
                ),
              ),
              child: Text(
                r[0].toUpperCase() + r.substring(1),
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
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
            ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_users.isEmpty) {
      return const Center(
        child: Text('No users found.',
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, i) {
          final user = _users[i];
          final isActive = user['is_active'] as bool? ?? true;
          final userId = user['id'] as int? ?? 0;
          return _UserTile(
            user: user,
            isActive: isActive,
            onToggle: () => _toggleUserStatus(userId, isActive),
          );
        },
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isActive;
  final VoidCallback onToggle;

  const _UserTile({
    required this.user,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final name = user['name'] as String? ?? 'Unknown';
    final role = user['role'] as String? ?? 'student';
    final email = user['email'] as String? ?? '';
    final regNo = user['reg_no'] as String? ?? '';

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
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryColor.withOpacity(0.12),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
                Text(
                  email.isNotEmpty ? email : regNo,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _RoleBadge(role: role),
                    const SizedBox(width: 6),
                    _StatusBadge(isActive: isActive),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              isActive
                  ? Icons.block_rounded
                  : Icons.check_circle_outline_rounded,
              color: isActive ? AppColors.errorColor : AppColors.successColor,
              size: 22,
            ),
            tooltip: isActive ? 'Suspend' : 'Activate',
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  Color get _color {
    switch (role) {
      case 'teacher':
        return AppColors.accentColor;
      case 'admin':
        return AppColors.warningColor;
      default:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.isNotEmpty
            ? role[0].toUpperCase() + role.substring(1)
            : role,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.successColor.withOpacity(0.12)
            : AppColors.errorColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Suspended',
        style: TextStyle(
          color: isActive ? AppColors.successColor : AppColors.errorColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
