import 'package:classly_frontend/utils/app_flow.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../widgets/animations/slide_animation.dart';
import '../widgets/animations/fade_animation.dart';
import 'auth/login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedRole;
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
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

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardsController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
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
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withOpacity(0.08),
              ),
            ),
          ),

          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.06),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header with Animation
                    SlideTransition(
                      position: _headerSlideAnimation,
                      child: FadeTransition(
                        opacity: _headerFadeAnimation,
                        child: _buildPremiumHeader(),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Student Role Card
                    _buildAnimatedRoleCard(
                      index: 0,
                      icon: Icons.person_rounded,
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
                      onTap: () => setState(() => _selectedRole = 'student'),
                    ),

                    const SizedBox(height: 24),

                    // Teacher Role Card
                    _buildAnimatedRoleCard(
                      index: 1,
                      icon: Icons.school_rounded,
                      title: 'Instructor',
                      description: 'Share knowledge with students',
                      details: [
                        'Create and manage courses',
                        'Upload video content',
                        'Track student progress',
                        'Earn from your content',
                      ],
                      isSelected: _selectedRole == 'teacher',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => setState(() => _selectedRole = 'teacher'),
                    ),

                    const SizedBox(height: 60),

                    // Continue Button
                    _buildContinueButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 26,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Choose Your Role',
          style: AppTextStyles.headingLarge.copyWith(
            fontSize: 32,
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select how you want to use Classly',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedRoleCard({
    required int index,
    required IconData icon,
    required String title,
    required String description,
    required List<String> details,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + (index * 200)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: SlideAnimation(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
              border: Border.all(
                color: isSelected
                    ? color
                    : Colors.grey.shade200,
                width: isSelected ? 2.5 : 1.5,
              ),
              color: isSelected
                  ? color.withOpacity(0.08)
                  : Colors.white,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                    spreadRadius: 4,
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
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
                    // Icon Container
                    ScaleTransition(
                      scale: AlwaysStoppedAnimation(isSelected ? 1.1 : 1.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 80,
                        height: 80,
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
                                    Colors.grey.shade100,
                                    Colors.grey.shade100,
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: color.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          size: 40,
                          color: isSelected ? Colors.white : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.headingSmall.copyWith(
                              fontSize: 24,
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Check Mark
                    if (isSelected)
                      ScaleTransition(
                        scale: AlwaysStoppedAnimation(1.0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Features List
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: details
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key < details.length - 1 ? 12 : 0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: color.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
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
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return FadeAnimation(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: _selectedRole != null
                  ? AppGradients.primaryGradient
                  : LinearGradient(
                      colors: [
                        Colors.grey.shade300,
                        Colors.grey.shade300,
                      ],
                    ),
              boxShadow: _selectedRole != null
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _selectedRole != null
                    ? () {
                        AppFlow.setUserRole(_selectedRole!);
                        Navigator.of(context).push(
                          SmoothPageTransition(
                            page: LoginScreen(selectedRole: _selectedRole!),
                          ),
                        );
                      }
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedRole == null
                            ? 'Select a Role to Continue'
                            : 'Continue as ${_selectedRole == 'student' ? 'Student' : 'Instructor'}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _selectedRole != null
                              ? Colors.white
                              : Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_selectedRole != null)
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: Colors.white.withOpacity(0.9),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedRole != null)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '✓ ${_selectedRole == 'student' ? 'Student Role' : 'Instructor Role'} selected',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;

  SmoothPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var fadeAnimation = animation.drive(
              Tween<double>(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: curve),
              ),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        );
}