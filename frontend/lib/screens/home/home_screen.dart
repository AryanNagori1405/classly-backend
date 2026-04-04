import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/slide_animation.dart';
import '../courses/courses_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const CoursesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceColor,
          border: Border(
            top: BorderSide(
              color: AppColors.borderColor,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textLight,
          selectedLabelStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTextStyles.caption,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: 24),
              activeIcon: Icon(Icons.dashboard, size: 24),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined, size: 24),
              activeIcon: Icon(Icons.school, size: 24),
              label: 'Courses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header Card
              FadeAnimation(
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome Back! 👋',
                                      style: AppTextStyles.headingMedium.copyWith(
                                        color: AppColors.surfaceColor,
                                        fontSize: 26,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      authProvider.user?.name ?? 'Student',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.surfaceColor
                                            .withOpacity(0.9),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.surfaceColor
                                        .withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: AppColors.surfaceColor,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.surfaceColor
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              authProvider.user?.role.toUpperCase() ?? 'STUDENT',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.surfaceColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.paddingXLarge),

              // Quick Stats Section
              FadeAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quick Stats',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 22,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            Icons.more_horiz,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppConstants.paddingMedium,
                      crossAxisSpacing: AppConstants.paddingMedium,
                      childAspectRatio: 1.1,
                      children: [
                        _buildStatCard(
                          title: 'Courses',
                          value: '5',
                          icon: Icons.school_outlined,
                          color: AppColors.primaryColor,
                        ),
                        _buildStatCard(
                          title: 'Videos',
                          value: '24',
                          icon: Icons.play_circle_outline,
                          color: AppColors.accentColor,
                        ),
                        _buildStatCard(
                          title: 'Completed',
                          value: '12',
                          icon: Icons.check_circle_outline,
                          color: AppColors.successColor,
                        ),
                        _buildStatCard(
                          title: 'Learning',
                          value: '8h 30m',
                          icon: Icons.timer_outlined,
                          color: AppColors.secondaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingXLarge),

              // Recent Courses Section
              FadeAnimation(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue Learning',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    SlideAnimation(
                      direction: SlideDirection.fromBottom,
                      child: _buildCourseCard(
                        title: 'Flutter Development',
                        instructor: 'Aryan Nagori',
                        progress: 0.65,
                        icon: Icons.mobile_friendly_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SlideAnimation(
                      direction: SlideDirection.fromBottom,
                      child: _buildCourseCard(
                        title: 'Advanced React',
                        instructor: 'Jane Doe',
                        progress: 0.42,
                        icon: Icons.web_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SlideAnimation(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.2,
          ),
          color: AppColors.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headingSmall.copyWith(
                color: color,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String instructor,
    required double progress,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.2,
        ),
        color: AppColors.surfaceColor,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor.withOpacity(0.2),
                      AppColors.secondaryColor.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by $instructor',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}