import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_flow.dart';
import '../../utils/first_time_user.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/slide_animation.dart';
import '../splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(children: [
                  // Profile Header Card
                  FadeAnimation(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusXLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Name
                          Text(
                            authProvider.user?.name ?? 'User',
                            style: AppTextStyles.headingMedium.copyWith(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Email
                          Text(
                            authProvider.user?.email ?? 'email@example.com',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              authProvider.user?.role.toUpperCase() ??
                                  'STUDENT',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildProfileStat(
                            label: 'Learning',
                            value: '8h',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildProfileStat(
                            label: 'Progress',
                            value: '65%',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Menu Items
                  FadeAnimation(
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Update your information',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit Profile - Coming soon'),
                                backgroundColor: AppColors.accentColor,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          subtitle: 'Manage your preferences',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Settings - Coming soon'),
                                backgroundColor: AppColors.accentColor,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'Get help from our team',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Help & Support - Coming soon'),
                                backgroundColor: AppColors.accentColor,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.info_outline,
                          title: 'About Classly',
                          subtitle: 'Version 1.0.0',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Classly',
                              applicationVersion: '1.0.0',
                              applicationLegalese:
                                  'Made with ❤️ for learning',
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildMenuItem(
                          icon: Icons.logout_outlined,
                          title: 'Logout',
                          subtitle: 'Sign out from your account',
                          isDestructive: true,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusLarge,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    AppConstants.paddingXLarge,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: AppColors.errorColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.logout_outlined,
                                          color: AppColors.errorColor,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Logout?',
                                        style: AppTextStyles.headingSmall
                                            .copyWith(
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Are you sure you want to logout from Classly?',
                                        textAlign: TextAlign.center,
                                        style:
                                            AppTextStyles.bodySmall.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    AppConstants.radiusMedium,
                                                  ),
                                                ),
                                                side: const BorderSide(
                                                  color: Colors.grey,
                                                  width: 1.2,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                authProvider.logout();
                                                AppFlow.reset();
                                                // Reset welcome screen so it shows again on next login
                                                await FirstTimeUserManager
                                                    .reset();

                                                if (context.mounted) {
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const SplashScreen(),
                                                    ),
                                                    (route) => false,
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.errorColor,
                                              ),
                                              child: const Text('Logout'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Footer
                  FadeAnimation(
                    child: Text(
                      'Made with ❤️ for learning',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primaryColor,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return SlideAnimation(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: isDestructive
                ? AppColors.errorColor.withOpacity(0.2)
                : Colors.grey.shade200,
            width: 1.2,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDestructive
                  ? AppColors.errorColor.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingMedium,
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDestructive
                          ? AppColors.errorColor.withOpacity(0.1)
                          : AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDestructive
                            ? AppColors.errorColor.withOpacity(0.2)
                            : AppColors.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isDestructive
                          ? AppColors.errorColor
                          : AppColors.primaryColor,
                      size: 22,
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
                            color: isDestructive
                                ? AppColors.errorColor
                                : Colors.black87,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}