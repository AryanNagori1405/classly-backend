import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_flow.dart';
import '../../widgets/animations/fade_animation.dart';
import '../splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;

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
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
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
                            final authProvider = context.read<AuthProvider>();
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
                child: Column(
                  children: [
                    // Header
                    SlideTransition(
                      position: _headerSlideAnimation,
                      child: FadeTransition(
                        opacity: _headerFadeAnimation,
                        child: _buildHeader(),
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingXLarge),

                    // Settings Sections
                    FadeAnimation(
                      child: Column(
                        children: [
                          // Notifications Section
                          _buildSettingsSection(
                            title: 'Notifications',
                            icon: Icons.notifications_rounded,
                            children: [
                              _buildToggleSetting(
                                title: 'Push Notifications',
                                subtitle: 'Receive important updates',
                                value: _notificationsEnabled,
                                onChanged: (value) {
                                  setState(() => _notificationsEnabled = value);
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildToggleSetting(
                                title: 'Sound',
                                subtitle: 'Play notification sounds',
                                value: _soundEnabled,
                                onChanged: (value) {
                                  setState(() => _soundEnabled = value);
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Display Section
                          _buildSettingsSection(
                            title: 'Display',
                            icon: Icons.brightness_4_rounded,
                            children: [
                              _buildToggleSetting(
                                title: 'Dark Mode',
                                subtitle: 'Easy on the eyes',
                                value: _darkModeEnabled,
                                onChanged: (value) {
                                  setState(() => _darkModeEnabled = value);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          const Text('Dark mode - Coming soon'),
                                      backgroundColor: AppColors.accentColor,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Account Section
                          _buildSettingsSection(
                            title: 'Account',
                            icon: Icons.person_rounded,
                            children: [
                              _buildSettingItem(
                                title: 'Privacy Policy',
                                subtitle: 'Read our privacy policy',
                                icon: Icons.privacy_tip_rounded,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Privacy Policy - Coming soon'),
                                      backgroundColor: AppColors.accentColor,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildSettingItem(
                                title: 'Terms of Service',
                                subtitle: 'View our terms',
                                icon: Icons.description_rounded,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          const Text('Terms - Coming soon'),
                                      backgroundColor: AppColors.accentColor,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildSettingItem(
                                title: 'Clear Cache',
                                subtitle: 'Free up storage space',
                                icon: Icons.delete_sweep_rounded,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Cache cleared ✓'),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Logout Section
                          _buildSettingsSection(
                            title: 'Session',
                            icon: Icons.logout_rounded,
                            children: [
                              _buildSettingItem(
                                title: 'Logout',
                                subtitle: 'Sign out from your account',
                                icon: Icons.logout_rounded,
                                color: AppColors.errorColor,
                                onTap: _showLogoutDialog,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppConstants.paddingXLarge),

                          // App Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Classly',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Version 1.0.0',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Made with ❤️ by Aryan Nagori',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppConstants.paddingLarge),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.black87,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 28,
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your preferences',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.2),
                    AppColors.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Section Content
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey.shade600,
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
    );
  }
}
