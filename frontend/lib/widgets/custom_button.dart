import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonType type;
  final double? width;
  final double? height;
  final IconData? icon;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.type = ButtonType.primary,
    this.width,
    this.height = 56,
    this.icon,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.durationShort,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isDisabled || widget.isLoading ? null : _onTapDown,
      onTapUp: widget.isDisabled || widget.isLoading ? null : _onTapUp,
      onTapCancel: _animationController.reverse,
      onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: _getButtonDecoration(),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.type == ButtonType.primary
                              ? AppColors.surfaceColor
                              : AppColors.primaryColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 20,
                            color: _getTextColor(),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: AppTextStyles.buttonText.copyWith(
                            color: _getTextColor(),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getButtonDecoration() {
    switch (widget.type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case ButtonType.secondary:
        return BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case ButtonType.outline:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: widget.isDisabled
                ? AppColors.borderColor
                : AppColors.primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        );
    }
  }

  Color _getTextColor() {
    if (widget.isDisabled) {
      return AppColors.textLight;
    }
    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return AppColors.surfaceColor;
      case ButtonType.outline:
        return AppColors.primaryColor;
    }
  }
}

enum ButtonType { primary, secondary, outline }