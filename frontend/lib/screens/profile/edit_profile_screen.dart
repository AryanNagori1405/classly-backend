import 'package:classly_frontend/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/animations/fade_animation.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  bool _isLoading = false;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

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

    // Initialize controllers with current user data
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _headerController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() => _isEditing = !_isEditing);
  }

    void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Update user data in AuthProvider
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      final updatedUser = User(
        regNo: authProvider.user!.regNo,
        name: _nameController.text,
        email: _emailController.text,
        phone: authProvider.user!.phone,
        role: authProvider.user!.role,
        profileImage: authProvider.user!.profileImage,
        bio: _bioController.text,
        createdAt: authProvider.user!.createdAt,
        isVerified: authProvider.user!.isVerified,
      );
      
      // Save to storage and update provider
      await StorageService.saveUser(updatedUser);
      authProvider.updateUser(updatedUser);
    }

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ Profile updated successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _cancelEdit() {
    final user = context.read<AuthProvider>().user;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _bioController.text = user?.bio ?? '';
    setState(() => _isEditing = false);
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
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final user = authProvider.user;
                    return Column(
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

                        // Profile Avatar Section
                        FadeAnimation(
                          child: _buildAvatarSection(user),
                        ),

                        const SizedBox(height: AppConstants.paddingXLarge),

                        // Edit Form
                        FadeAnimation(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Name Field
                                _buildEditableField(
                                  label: 'Full Name',
                                  controller: _nameController,
                                  icon: Icons.person_rounded,
                                  enabled: _isEditing,
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

                                const SizedBox(height: 16),

                                // Email Field
                                _buildEditableField(
                                  label: 'Email Address',
                                  controller: _emailController,
                                  icon: Icons.email_rounded,
                                  enabled: _isEditing,
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

                                const SizedBox(height: 16),

                                // Bio Field
                                _buildEditableField(
                                  label: 'Bio',
                                  controller: _bioController,
                                  icon: Icons.description_rounded,
                                  enabled: _isEditing,
                                  maxLines: 4,
                                  validator: (value) {
                                    if (value != null && value.length > 250) {
                                      return 'Bio cannot exceed 250 characters';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(
                                    height: AppConstants.paddingXLarge),

                                // Buttons
                                _buildActionButtons(),

                                const SizedBox(
                                    height: AppConstants.paddingLarge),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Saving changes...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
                'Edit Profile',
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 28,
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Update your information',
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

  Widget _buildAvatarSection(User? user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 55,
                  color: AppColors.primaryColor,
                ),
              ),
              // Edit Avatar Button
              if (_isEditing)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Upload photo - Coming soon'),
                            backgroundColor: AppColors.accentColor,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user?.name ?? 'User',
            style: AppTextStyles.headingSmall.copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user?.email ?? 'email@example.com',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              maxLines: maxLines,
              validator: validator,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color:
                      enabled ? AppColors.primaryColor : Colors.grey.shade400,
                  size: 20,
                ),
                filled: true,
                fillColor: enabled ? Colors.white : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 2.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.errorColor,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.errorColor,
                    width: 2.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: maxLines > 1 ? 14 : 14,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
                errorStyle: const TextStyle(
                  color: AppColors.errorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_isEditing) {
      // Edit Mode Button
      return SizedBox(
        width: double.infinity,
        height: 58,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleEditMode,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withOpacity(0.2),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Profile',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Save and Cancel Buttons
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : _cancelEdit,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
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
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _saveChanges,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Save Changes',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
