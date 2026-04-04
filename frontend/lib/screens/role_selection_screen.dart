import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../widgets/animations/slide_animation.dart';
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          AppStrings.selectRole,
          style: AppTextStyles.headingMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Who are you?',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Select your role to get started with Classly',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 40),
              // Student Role Card
              SlideAnimation(
                direction: SlideDirection.fromLeft,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = 'student'),
                  child: _buildRoleCard(
                    icon: Icons.person_outline,
                    title: AppStrings.student,
                    description: 'Learn from expert instructors',
                    isSelected: _selectedRole == 'student',
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
                    title: AppStrings.teacher,
                    description: 'Share knowledge with students',
                    isSelected: _selectedRole == 'teacher',
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // Continue Button
              CustomButton(
                label: 'Continue',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
  }) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.05)
              : AppColors.surfaceColor,
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? const [
                          AppColors.primaryColor,
                          AppColors.secondaryColor,
                        ]
                      : [
                          AppColors.borderColor,
                          AppColors.borderColor,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 40,
                color: isSelected ? AppColors.surfaceColor : AppColors.textLight,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: 4),
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
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.surfaceColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}