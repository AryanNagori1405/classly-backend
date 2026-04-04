import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/animations/fade_animation.dart';
import '../../widgets/animations/slide_animation.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final String selectedRole;

  const SignupScreen({
    Key? key,
    required this.selectedRole,
  }) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠ Please agree to terms and conditions'),
            backgroundColor: AppColors.warningColor,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Account created successfully!'),
              backgroundColor: AppColors.successColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          child: FadeAnimation(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header
                SlideAnimation(
                  direction: SlideDirection.fromTop,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: AppTextStyles.headingLarge.copyWith(
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          text: 'Join as ',
                          style: AppTextStyles.bodyMedium,
                          children: [
                            TextSpan(
                              text: widget.selectedRole.toUpperCase(),
                              style: AppTextStyles.bodyMedium.copyWith(
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
                const SizedBox(height: 40),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      SlideAnimation(
                        direction: SlideDirection.fromLeft,
                        child: CustomTextField(
                          label: 'Full Name',
                          hint: 'John Doe',
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            if (value.length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email Field
                      SlideAnimation(
                        direction: SlideDirection.fromRight,
                        child: CustomTextField(
                          label: 'Email Address',
                          hint: 'name@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Password Field
                      SlideAnimation(
                        direction: SlideDirection.fromLeft,
                        child: CustomTextField(
                          label: 'Password',
                          hint: 'Create a strong password',
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Confirm Password Field
                      SlideAnimation(
                        direction: SlideDirection.fromRight,
                        child: CustomTextField(
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          controller: _confirmPasswordController,
                          obscureText: !_showConfirmPassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _showConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Terms & Conditions
                      SlideAnimation(
                        direction: SlideDirection.fromBottom,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            color: AppColors.surfaceColor,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(
                                      () => _agreeToTerms = value ?? false,
                                    );
                                  },
                                  activeColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: AppTextStyles.bodySmall,
                                    children: [
                                      TextSpan(
                                        text: 'Terms & Conditions',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' and ',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Signup Button
                      SlideAnimation(
                        direction: SlideDirection.fromBottom,
                        child: CustomButton(
                          label: 'Create Account',
                          onPressed: _handleSignup,
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Login Link
                      SlideAnimation(
                        direction: SlideDirection.fromBottom,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: AppTextStyles.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(
                                      selectedRole: widget.selectedRole,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign In',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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
}