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
          const SnackBar(content: Text('Please agree to terms and conditions')),
        );
        return;
      }

      setState(() => _isLoading = true);
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup successful!')),
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
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
                      const SizedBox(height: 8),
                      Text(
                        'Sign up as ${widget.selectedRole}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      SlideAnimation(
                        direction: SlideDirection.fromLeft,
                        child: CustomTextField(
                          label: AppStrings.fullName,
                          hint: 'Enter your full name',
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
                      const SizedBox(height: 20),
                      // Email Field
                      SlideAnimation(
                        direction: SlideDirection.fromRight,
                        child: CustomTextField(
                          label: AppStrings.email,
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
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
                      const SizedBox(height: 20),
                      // Password Field
                      SlideAnimation(
                        direction: SlideDirection.fromLeft,
                        child: CustomTextField(
                          label: AppStrings.password,
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          prefixIcon: Icons.lock_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Confirm Password Field
                      SlideAnimation(
                        direction: SlideDirection.fromRight,
                        child: CustomTextField(
                          label: AppStrings.confirmPassword,
                          hint: 'Confirm your password',
                          controller: _confirmPasswordController,
                          obscureText: !_showConfirmPassword,
                          prefixIcon: Icons.lock_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Terms & Conditions
                      SlideAnimation(
                        direction: SlideDirection.fromBottom,
                        child: Row(
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() => _agreeToTerms = value ?? false);
                              },
                              activeColor: AppColors.primaryColor,
                            ),
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
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Signup Button
                      SlideAnimation(
                        direction: SlideDirection.fromBottom,
                        child: CustomButton(
                          label: AppStrings.signUp,
                          onPressed: _handleSignup,
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.haveAccount,
                            style: AppTextStyles.bodySmall,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(
                                    selectedRole: widget.selectedRole,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              AppStrings.login,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
}