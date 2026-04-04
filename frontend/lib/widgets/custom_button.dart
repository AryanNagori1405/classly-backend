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
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _animationController.reverse,
      onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: _getButtonColor().withOpacity(
                      0.3 * _elevationAnimation.value / 8,
                    ),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: _getButtonDecoration(),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
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
                                const SizedBox(width: 10),
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
        },
      ),
    );
  }

  Color _getButtonColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return AppColors.primaryColor;
      case ButtonType.secondary:
        return AppColors.secondaryColor;
      case ButtonType.outline:
        return AppColors.primaryColor;
    }
  }

  BoxDecoration _getButtonDecoration() {
    if (widget.isDisabled) {
      return BoxDecoration(
        color: AppColors.borderColor,
        borderRadius: BorderRadius.circular(14),
      );
    }

    switch (widget.type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        );
      case ButtonType.secondary:
        return BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(14),
        );
      case ButtonType.outline:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: AppColors.primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
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