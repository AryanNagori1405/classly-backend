import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import 'uid_login_screen.dart';

class UIDSignupScreen extends StatefulWidget {
  final String selectedRole;

  const UIDSignupScreen({
    Key? key,
    required this.selectedRole,
  }) : super(key: key);

  @override
  State<UIDSignupScreen> createState() => _UIDSignupScreenState();
}

class _UIDSignupScreenState extends State<UIDSignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _uidController = TextEditingController();
  final _regIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _semesterController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeToTerms = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
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
    _nameController.dispose();
    _emailController.dispose();
    _uidController.dispose();
    _regIdController.dispose();
    _departmentController.dispose();
    _semesterController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to terms and conditions'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }

      // In UID-based auth, signup is done by admin.
      // Direct user to the UID login flow instead.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Registration is managed by your institution. Use your UID or Registration ID to log in.'),
          duration: Duration(seconds: 4),
        ),
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const UIDLoginScreen()),
          (route) => false,
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS - DECLARED BEFORE build() method
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool showPassword = false,
    Function(bool)? onShowPasswordChanged,
    String? Function(String?)? validator,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword && !showPassword,
          validator: validator,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.primaryColor.withOpacity(0.6),
            ),
            suffixIcon: isPassword
                ? GestureDetector(
                    onTap: () {
                      onShowPasswordChanged?.call(!showPassword);
                    },
                    child: Icon(
                      showPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.primaryColor.withOpacity(0.6),
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.errorColor,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String label,
    required VoidCallback onPressed,
    required bool isLoading,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD METHOD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.03),

                      // Logo Animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 50,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Title
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Join Classly Community',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Signing up as ${widget.selectedRole.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // Name Field
                      _buildAnimatedTextField(
                        controller: _nameController,
                        hintText: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                        delay: 0,
                      ),

                      const SizedBox(height: 16),

                      // Email Field
                      _buildAnimatedTextField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        icon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        delay: 100,
                      ),

                      const SizedBox(height: 16),

                      // UID Field
                      _buildAnimatedTextField(
                        controller: _uidController,
                        hintText: 'UID',
                        icon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'UID is required';
                          }
                          return null;
                        },
                        delay: 200,
                      ),

                      const SizedBox(height: 16),

                      // Registration ID Field
                      _buildAnimatedTextField(
                        controller: _regIdController,
                        hintText: 'Registration ID',
                        icon: Icons.assignment_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Registration ID is required';
                          }
                          return null;
                        },
                        delay: 300,
                      ),

                      const SizedBox(height: 16),

                      // Department Field
                      _buildAnimatedTextField(
                        controller: _departmentController,
                        hintText: 'Department',
                        icon: Icons.business_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Department is required';
                          }
                          return null;
                        },
                        delay: 400,
                      ),

                      const SizedBox(height: 16),

                      // Semester Field
                      _buildAnimatedTextField(
                        controller: _semesterController,
                        hintText: 'Semester',
                        icon: Icons.school_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Semester is required';
                          }
                          return null;
                        },
                        delay: 500,
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      _buildAnimatedTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        showPassword: _showPassword,
                        onShowPasswordChanged: (value) {
                          setState(() => _showPassword = value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        delay: 600,
                      ),

                      const SizedBox(height: 16),

                      // Confirm Password Field
                      _buildAnimatedTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        showPassword: _showConfirmPassword,
                        onShowPasswordChanged: (value) {
                          setState(() => _showConfirmPassword = value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm password';
                          }
                          return null;
                        },
                        delay: 700,
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Terms & Conditions
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() => _agreeToTerms = value ?? false);
                                },
                                activeColor: AppColors.primaryColor,
                                checkColor: Colors.white,
                                side: const BorderSide(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to ',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: 'Terms & Conditions',
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.bold,
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

                      SizedBox(height: size.height * 0.03),

                      // Sign Up Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return _buildAnimatedButton(
                            label: 'Create Account',
                            onPressed: _handleSignup,
                            isLoading: authProvider.isLoading,
                            delay: 800,
                          );
                        },
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Login Link
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1600),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}