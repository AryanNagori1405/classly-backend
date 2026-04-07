import 'package:classly_frontend/screens/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/slide_animation.dart';
import '../video/video_list_screen.dart';
import '../video/my_contributions_screen.dart';
import '../community/community_list_screen.dart';
import '../doubts/doubts_list_screen.dart';
import '../profile/profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _screens = [
      const StudentDashboardTab(),
      const VideoListScreen(),
      const CommunityListScreen(),
      const DoubtsListScreen(),
      const ProfileScreen(),
    ];

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildPremiumBottomNav(),
    );
  }

  Widget _buildPremiumBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _fabController.forward(from: 0);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: AppTextStyles.caption.copyWith(
          fontSize: 11,
          letterSpacing: 0.3,
        ),
        type: BottomNavigationBarType.fixed,
        items: [
          _buildNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isActive: _selectedIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.play_circle_outline,
            activeIcon: Icons.play_circle_rounded,
            label: 'Lectures',
            isActive: _selectedIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups_rounded,
            label: 'Community',
            isActive: _selectedIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.help_outline,
            activeIcon: Icons.help_rounded,
            label: 'Doubts',
            isActive: _selectedIndex == 3,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
            isActive: _selectedIndex == 4,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Icon(icon, size: 24),
      ),
      activeIcon: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(activeIcon, size: 24),
        ),
      ),
      label: label,
    );
  }
}

class StudentDashboardTab extends StatefulWidget {
  const StudentDashboardTab({Key? key}) : super(key: key);

  @override
  State<StudentDashboardTab> createState() => _StudentDashboardTabState();
}

class _StudentDashboardTabState extends State<StudentDashboardTab>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  int _videosWatched = 0;
  int _doubtsAsked = 0;
  int _communitiesJoined = 0;
  int _downloaded = 0;
  List<dynamic> _expiringVideos = [];
  bool _statsLoading = false;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    _headerFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeInCubic),
    );
    _headerController.forward();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _statsLoading = true);
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      if (mounted) setState(() => _statsLoading = false);
      return;
    }
    try {
      final results = await Future.wait([
        ApiService().getWatchHistory(token: token),
        ApiService().getExpiringVideos(token: token),
      ]);
      if (!mounted) return;
      final historyData = results[0];
      final expiringData = results[1];
      final history = historyData['watch_history'] as List? ?? [];
      final uniqueIds = history.map((e) => e['video_id']).toSet();
      final expiring = expiringData['videos'] as List? ?? [];
      setState(() {
        _videosWatched = uniqueIds.length;
        _expiringVideos = expiring;
        _statsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header with Animation
                  SlideTransition(
                    position: _headerSlideAnimation,
                    child: FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: _buildPremiumHeader(authProvider),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Expiring Videos Section
                  FadeAnimation(
                    child:
                        _buildSectionTitle('Expiring Soon ⏰', showIcon: true),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  FadeAnimation(
                    child: _buildExpiringVideosSection(),
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Quick Actions
                  FadeAnimation(
                    child: _buildSectionTitle('Quick Actions', showIcon: false),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  FadeAnimation(
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppConstants.paddingMedium,
                      crossAxisSpacing: AppConstants.paddingMedium,
                      childAspectRatio: 1.15,
                      children: [
                        _buildQuickActionCard(
                          icon: Icons.play_circle_outline,
                          label: 'Watch Lectures',
                          color: AppColors.primaryColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VideoListScreen(),
                              ),
                            );
                          },
                          delay: 0,
                        ),
                        _buildQuickActionCard(
                          icon: Icons.groups_outlined,
                          label: 'Join Community',
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CommunityListScreen(),
                              ),
                            );
                          },
                          delay: 100,
                        ),
                        _buildQuickActionCard(
                          icon: Icons.help_outline,
                          label: 'Ask Doubts',
                          color: const Color(0xFFF59E0B),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DoubtsListScreen(),
                              ),
                            );
                          },
                          delay: 200,
                        ),
                        _buildQuickActionCard(
                          icon: Icons.upload_file_outlined,
                          label: 'My Contributions',
                          color: const Color(0xFF10B981),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MyContributionsScreen(),
                              ),
                            );
                          },
                          delay: 300,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Stats Section
                  FadeAnimation(
                    child: _buildSectionTitle('Your Progress', showIcon: false),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  FadeAnimation(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'Videos\nWatched',
                            value: _videosWatched.toString(),
                            icon: Icons.play_circle_outline,
                            color: AppColors.primaryColor,
                            delay: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Doubts\nAsked',
                            value: _doubtsAsked.toString(),
                            icon: Icons.help_outline,
                            color: const Color(0xFFF59E0B),
                            delay: 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeAnimation(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            label: 'Communities',
                            value: _communitiesJoined.toString(),
                            icon: Icons.groups_outlined,
                            color: const Color(0xFF8B5CF6),
                            delay: 200,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            label: 'Downloaded',
                            value: _downloaded.toString(),
                            icon: Icons.download_outlined,
                            color: const Color(0xFF10B981),
                            delay: 300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back! 👋',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.user?.name ?? 'Student',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Search Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Notifications Button
          ScaleTransition(
            scale: AlwaysStoppedAnimation(1.0),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notifications - Coming soon'),
                        backgroundColor: AppColors.accentColor,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringVideosSection() {
    if (_statsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_expiringVideos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 12),
            Text('No videos expiring soon 🎉'),
          ],
        ),
      );
    }
    return Column(
      children: _expiringVideos.take(3).map((video) {
        final daysRemaining = video['days_remaining'] as int? ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildExpiringVideoCard(
            title: video['title'] ?? 'Unknown',
            teacher: video['teacher_name'] ?? 'Unknown',
            daysRemaining: daysRemaining,
            subject: video['subject'] ?? '',
            thumbnail: Icons.play_circle_outline,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title, {required bool showIcon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        if (showIcon)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFFF59E0B),
              size: 18,
            ),
          ),
      ],
    );
  }

  Widget _buildExpiringVideoCard({
    required String title,
    required String teacher,
    required int daysRemaining,
    required String subject,
    required IconData thumbnail,
  }) {
    return SlideAnimation(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: const Color(0xFFF59E0B).withOpacity(0.2),
            width: 1.5,
          ),
          color: const Color(0xFFF59E0B).withOpacity(0.05),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(0.2),
                    const Color(0xFFF59E0B).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                thumbnail,
                color: const Color(0xFFF59E0B),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'by $teacher • $subject',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                  width: 1.2,
                ),
              ),
              child: Text(
                '$daysRemaining day${daysRemaining > 1 ? 's' : ''}',
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFFF59E0B),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: SlideAnimation(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: Colors.grey.shade100,
              width: 1.5,
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              splashColor: color.withOpacity(0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: color.withOpacity(0.2),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, anim, child) {
        return Transform.scale(
          scale: 0.8 + (anim * 0.2),
          child: Opacity(
            opacity: anim,
            child: child,
          ),
        );
      },
      child: SlideAnimation(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: Colors.grey.shade100,
              width: 1.5,
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: AppTextStyles.headingSmall.copyWith(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
