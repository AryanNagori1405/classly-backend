import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/animations/scale_animation.dart';
import '../widgets/animations/fade_animation.dart';
import 'role_selection_screen.dart';
import '../../config/constraints.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    _navigateToNext();
  }

  void _navigateToNext() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RoleSelectionScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with rotation animation
            ScaleAnimation(
              beginScale: 0.5,
              duration: const Duration(milliseconds: 1500),
              child: RotationTransition(
                turns: _rotationAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: AppColors.secondaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(-8, -8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school,
                        size: 60,
                        color: AppColors.surfaceColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            // App Name with gradient
            FadeAnimation(
              duration: const Duration(milliseconds: 1000),
              begin: 0.3,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Classly',
                  style: AppTextStyles.headingLarge.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.surfaceColor,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tagline
            FadeAnimation(
              duration: const Duration(milliseconds: 1200),
              begin: 0.2,
              child: Text(
                'Learn & Teach Together',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 80),
            // Loading Indicator with custom design
            FadeAnimation(
              duration: const Duration(milliseconds: 1400),
              begin: 0.1,
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer circle
                        const SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                            strokeWidth: 3,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.school,
                              size: 20,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Starting your journey...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}