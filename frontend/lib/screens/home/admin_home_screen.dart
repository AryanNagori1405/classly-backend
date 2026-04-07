import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/animations/fade_animation.dart';
import '../profile/profile_screen.dart';
import '../admin/user_management_screen.dart';
import '../admin/community_moderation_screen.dart';
import '../admin/feedback_tracking_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = const [
    _AdminDashboardTab(),
    UserManagementScreen(),
    CommunityModerationScreen(),
    FeedbackTrackingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          _fabController.forward(from: 0);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Users'),
          BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups_rounded),
              label: 'Communities'),
          BottomNavigationBarItem(
              icon: Icon(Icons.feedback_outlined),
              activeIcon: Icon(Icons.feedback_rounded),
              label: 'Feedback'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
      ),
    );
  }
}

class _AdminDashboardTab extends StatefulWidget {
  const _AdminDashboardTab();

  @override
  State<_AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<_AdminDashboardTab> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic> _stats = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final token = context.read<AuthProvider>().token!;
      final usersResult = await _apiService.adminGetUsers(token: token);
      final users = usersResult['users'] as List? ?? [];
      setState(() {
        _stats = {
          'total_users': users.length,
          'students': users.where((u) => u['role'] == 'student').length,
          'teachers': users.where((u) => u['role'] == 'teacher').length,
        };
      });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeAnimation(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Admin Panel',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Welcome, ${user?.name ?? 'Admin'}',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryColor,
                                AppColors.primaryLight
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.admin_panel_settings_rounded,
                              color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor),
                      ),
                    )
                  else
                    _buildStatsGrid(),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatsCard(
          label: 'Total Users',
          value: '${_stats['total_users'] ?? 0}',
          icon: Icons.people_rounded,
          color: AppColors.primaryColor,
        ),
        _StatsCard(
          label: 'Students',
          value: '${_stats['students'] ?? 0}',
          icon: Icons.school_rounded,
          color: AppColors.accentColor,
        ),
        _StatsCard(
          label: 'Teachers',
          value: '${_stats['teachers'] ?? 0}',
          icon: Icons.cast_for_education_rounded,
          color: AppColors.warningColor,
        ),
        _StatsCard(
          label: 'Admins',
          value: '1',
          icon: Icons.admin_panel_settings_rounded,
          color: AppColors.infoColor,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _QuickActionTile(
          label: 'Manage Users',
          subtitle: 'Activate or suspend user accounts',
          icon: Icons.manage_accounts_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const UserManagementScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _QuickActionTile(
          label: 'Community Moderation',
          subtitle: 'Review and moderate communities',
          icon: Icons.groups_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CommunityModerationScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _QuickActionTile(
          label: 'Feedback Tracking',
          subtitle: 'View all anonymous feedback',
          icon: Icons.feedback_rounded,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const FeedbackTrackingScreen()),
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
