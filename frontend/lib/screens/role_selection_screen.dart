import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constraints.dart';
import '../widgets/animations/slide_animation.dart';
import '../widgets/animations/fade_animation.dart';
import '../widgets/custom_button.dart';
import 'auth/login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                FadeAnimation(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Classly',
                        style: AppTextStyles.headingLarge.copyWith(
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose your role to get started',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // Student Role Card
                SlideAnimation(
                  direction: SlideDirection.fromLeft,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRole = 'student'),
                    child: _buildRoleCard(
                      icon: Icons.person_outline,
                      title: 'Student',
                      description: 'Learn from expert instructors',
                      details: [
                        'Access thousands of courses',
                        'Learn at your own pace',
                        'Get certificates',
                        'Join community forums',
                      ],
                      isSelected: _selectedRole == 'student',
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Teacher Role Card
                SlideAnimation(
                  direction: SlideDirection.fromRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRole = 'teacher'),
                    child: _buildRoleCard(
                      icon: Icons.school_outlined,
                      title: 'Teacher',
                      description: 'Share knowledge with students',
                      details: [
                        'Create and manage courses',
                        'Upload video content',
                        'Track student progress',
                        'Earn from your content',
                      ],
                      isSelected: _selectedRole == 'teacher',
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Continue Button
                FadeAnimation(
                  child: Column(
                    children: [
                      CustomButton(
                        label: _selectedRole == null
                            ? 'Select a Role to Continue'
                            : 'Continue',
                        onPressed: _selectedRole != null
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LoginScreen(selectedRole: _selectedRole!),
                                  ),
                                )
                            : () {},
                        isDisabled: _selectedRole == null,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedRole != null)
                        Text(
                          'You selected: ${_selectedRole!.toUpperCase()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> details,
    required bool isSelected,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: isSelected ? color : AppColors.borderColor,
          width: isSelected ? 2.0 : 1.2,
        ),
        color: isSelected
            ? color.withOpacity(0.05)
            : AppColors.surfaceColor,
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          else
            const BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            color,
                            color.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            AppColors.borderColor,
                            AppColors.borderColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: isSelected
                      ? AppColors.surfaceColor
                      : AppColors.textLight,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 22,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.surfaceColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Details List
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.15),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details
                  .map(
                    (detail) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: color,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              detail,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}