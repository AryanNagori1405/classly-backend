import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_flow.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/slide_animation.dart';
import '../splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

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
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    _headerFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeInCubic),
    );
    _headerController.forward();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Animated Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.08),
                  AppColors.primaryLight.withOpacity(0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Animated Background Shapes
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.08),
              ),
            ),
          ),

          // Main Content
          SafeArea(
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
                      children: [
                        // Profile Header Card
                        SlideTransition(
                          position: _headerSlideAnimation,
                          child: FadeTransition(
                            opacity: _headerFadeAnimation,
                            child: _buildPremiumHeader(authProvider),
                          ),
                        ),

                        const SizedBox(height: AppConstants.paddingXLarge),

                        // Stats Section
                        FadeAnimation(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildProfileStat(
                                  label: 'Courses',
                                  value: '5',
                                  icon: Icons.book_rounded,
                                  color: AppColors.primaryColor,
                                  delay: 0,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildProfileStat(
                                  label: 'Learning',
                                  value: '8h',
                                  icon: Icons.schedule_rounded,
                                  color: const Color(0xFF06B6D4),
                                  delay: 100,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildProfileStat(
                                  label: 'Progress',
                                  value: '65%',
                                  icon: Icons.trending_up_rounded,
                                  color: const Color(0xFF10B981),
                                  delay: 200,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppConstants.paddingXLarge),

                        // Menu Items Section Title
                        FadeAnimation(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Settings & More',
                              style: AppTextStyles.headingSmall.copyWith(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppConstants.paddingMedium),

                        // Menu Items
                        FadeAnimation(
                          child: Column(
                            children: [
                              _buildAnimatedMenuItem(
                                icon: Icons.person_rounded,
                                title: 'Edit Profile',
                                subtitle: 'Update your information',
                                color: AppColors.primaryColor,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Edit Profile - Coming soon'),
                                      backgroundColor:
                                          AppColors.accentColor,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                delay: 0,
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedMenuItem(
                                icon: Icons.settings_rounded,
                                title: 'Settings',
                                subtitle: 'Manage your preferences',
                                color: const Color(0xFF8B5CF6),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          const Text('Settings - Coming soon'),
                                      backgroundColor:
                                          AppColors.accentColor,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                delay: 100,
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedMenuItem(
                                icon: Icons.help_rounded,
                                title: 'Help & Support',
                                subtitle: 'Get help from our team',
                                color: const Color(0xFFF59E0B),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Help & Support - Coming soon'),
                                      backgroundColor:
                                          AppColors.accentColor,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                delay: 200,
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedMenuItem(
                                icon: Icons.info_rounded,
                                title: 'About Classly',
                                subtitle: 'Version 1.0.0',
                                color: const Color(0xFF06B6D4),
                                onTap: () {
                                  showAboutDialog(
                                    context: context,
                                    applicationName: 'Classly',
                                    applicationVersion: '1.0.0',
                                    applicationLegalese:
                                        'Made with ❤️ for learning',
                                  );
                                },
                                delay: 300,
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedMenuItem(
                                icon: Icons.logout_rounded,
                                title: 'Logout',
                                subtitle: 'Sign out from your account',
                                color: AppColors.errorColor,
                                isDestructive: true,
                                onTap: () {
                                  _showLogoutDialog(context, authProvider);
                                },
                                delay: 400,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppConstants.paddingXLarge),

                        // Footer
                        FadeAnimation(
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: AppGradients.primaryGradient,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Made with ❤️ by Aryan Nagori',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Version 1.0.0',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
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
          ),
        ],
      ),
    );
  }

    Widget _buildPremiumHeader(AuthProvider authProvider) {
    final user = authProvider.user;
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      child: Column(
        children: [
          // Avatar with Float Animation
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 55,
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Name
          Text(
            user?.name ?? 'User',
            style: AppTextStyles.headingMedium.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // Email
          Text(
            user?.email ?? 'email@example.com',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          // Role Badge with Icon
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user?.role == 'student'
                      ? Icons.person_rounded
                      : Icons.school_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  user?.role.toUpperCase() ?? 'STUDENT',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Student Details Card
          _buildStudentDetailsCard(user),
        ],
      ),
    );
  }

  Widget _buildStudentDetailsCard(User? user) {
    if (user == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            user.role == 'student' ? 'Student Details' : 'Instructor Details',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 14),

          // UID Row
          _buildDetailRow(
            icon: Icons.badge_rounded,
            label: 'UID',
            value: user.uid,
          ),

          const SizedBox(height: 12),

          // Registration ID Row
          _buildDetailRow(
            icon: Icons.assignment_rounded,
            label: 'Registration ID',
            value: user.regId,
          ),

          const SizedBox(height: 12),

          // Department Row
          _buildDetailRow(
            icon: Icons.business_rounded,
            label: 'Department',
            value: user.department,
          ),

          const SizedBox(height: 12),

          // Semester Row
          _buildDetailRow(
            icon: Icons.school_rounded,
            label: 'Semester',
            value: user.semester,
          ),

          if (user.role == 'teacher') ...[
            const SizedBox(height: 12),
            // Divider
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 12),

            // Courses Count (for teachers)
            _buildDetailRow(
              icon: Icons.book_rounded,
              label: 'Courses Created',
              value: user.coursesCount.toString(),
            ),

            const SizedBox(height: 12),

            // Videos Count (for teachers)
            _buildDetailRow(
              icon: Icons.video_library_rounded,
              label: 'Videos Uploaded',
              value: user.videosCount.toString(),
            ),

            const SizedBox(height: 12),

            // Rating (for teachers)
            _buildDetailRow(
              icon: Icons.star_rounded,
              label: 'Rating',
              value: '${user.rating.toStringAsFixed(1)} ⭐',
              valueColor: const Color(0xFFFCD34D),
            ),
          ] else ...[
            const SizedBox(height: 12),
            // Divider
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 12),

            // Enrolled Courses (for students)
            _buildDetailRow(
              icon: Icons.library_books_rounded,
              label: 'Enrolled Courses',
              value: user.enrolledCourses.length.toString(),
            ),

            const SizedBox(height: 12),

            // Communities (for students)
            _buildDetailRow(
              icon: Icons.groups_rounded,
              label: 'Communities Joined',
              value: user.joinedCommunities.length.toString(),
            ),
          ],

          if (user.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Divider
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.15),
            ),
            const SizedBox(height: 12),

            // Bio Section
            Text(
              'About',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.bio,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStat({
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingMedium,
          ),
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
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
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
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: AppTextStyles.headingSmall.copyWith(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
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
              color: isDestructive
                  ? color.withOpacity(0.2)
                  : Colors.grey.shade100,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingMedium,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
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
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 26,
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
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingXLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.errorColor.withOpacity(0.15),
                      AppColors.errorColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.errorColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.errorColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Logout?',
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.black87,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout from Classly?',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                        ),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.errorColor,
                            AppColors.errorColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMedium,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.errorColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            authProvider.logout();
                            AppFlow.reset();

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const SplashScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                'Logout',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}