import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'role_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInCubic),
    );

    // Slide Animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Float Animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.06),

                    // Welcome Icon with Floating Animation
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppGradients.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor
                                        .withOpacity(0.4),
                                    blurRadius: 40,
                                    offset: const Offset(0, 16),
                                    spreadRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: AppColors.primaryColor
                                        .withOpacity(0.2),
                                    blurRadius: 80,
                                    offset: const Offset(0, 32),
                                    spreadRadius: 16,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                size: 65,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: size.height * 0.06),

                    // Welcome Title with Animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppColors.primaryColor,
                                AppColors.primaryColor.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'Welcome to Classly',
                              style: AppTextStyles.headingLarge.copyWith(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: AppGradients.primaryGradient,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Subtitle
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Your Classroom Lecture Sharing Platform',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: size.height * 0.10),

                    // Features List with Staggered Animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            _buildFeatureItem(
                              icon: Icons.play_circle_rounded,
                              title: 'Watch Lectures',
                              description: 'Access recorded classroom lectures anytime, anywhere',
                              color: AppColors.primaryColor,
                              delay: 0,
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureItem(
                              icon: Icons.people_rounded,
                              title: 'Join Communities',
                              description: 'Connect and collaborate with classmates seamlessly',
                              color: const Color(0xFF8B5CF6),
                              delay: 100,
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureItem(
                              icon: Icons.lightbulb_rounded,
                              title: 'Ask Doubts',
                              description: 'Get instant clarifications from peers and instructors',
                              color: const Color(0xFFF59E0B),
                              delay: 200,
                            ),
                            const SizedBox(height: 16),
                            _buildFeatureItem(
                              icon: Icons.download_rounded,
                              title: 'Download Content',
                              description: 'Save lectures for offline viewing anytime',
                              color: const Color(0xFF10B981),
                              delay: 300,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.12),

                    // Start Button
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 60 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            SmoothPageTransition(
                              page: const RoleSelectionScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: AppGradients.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.4),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  SmoothPageTransition(
                                    page: const RoleSelectionScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(18),
                              splashColor: Colors.white.withOpacity(0.2),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.08),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 900 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade500,
                      height: 1.5,
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