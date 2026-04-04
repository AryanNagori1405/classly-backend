import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final int minLines;
  final bool readOnly;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _borderColorAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _focusAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _borderColorAnimation = ColorTween(
      begin: AppColors.borderColor,
      end: AppColors.primaryColor,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppConstants.isMobile(context);
    final iconSize = isMobile
        ? AppConstants.iconSizeMedium
        : AppConstants.iconSizeLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppConstants.spacingUnit * 1.25),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
            if (hasFocus) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          child: AnimatedBuilder(
            animation: _focusAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusMedium,
                  ),
                  boxShadow: [
                    if (_isFocused)
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(
                          0.2 * _focusAnimation.value,
                        ),
                        blurRadius: 12 * _focusAnimation.value,
                        spreadRadius: 2 * _focusAnimation.value,
                      ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minHeight: AppConstants.inputFieldHeight,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  maxLines: widget.obscureText ? 1 : widget.maxLines,
                  minLines: widget.minLines,
                  readOnly: widget.readOnly,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    labelText: widget.label,
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            color: _isFocused
                                ? AppColors.primaryColor
                                : AppColors.textLight,
                            size: iconSize,
                          )
                        : null,
                    suffixIcon: widget.suffixIcon != null
                        ? Icon(
                            widget.suffixIcon,
                            color: _isFocused
                                ? AppColors.primaryColor
                                : AppColors.textLight,
                            size: iconSize,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                        width: AppConstants.borderWidthMedium,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.borderColor.withOpacity(0.8),
                        width: AppConstants.borderWidthMedium,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: _borderColorAnimation.value ??
                            AppColors.primaryColor,
                        width: AppConstants.borderWidthThick,
                      ),
                    ),
                    fillColor: AppColors.backgroundColor,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}