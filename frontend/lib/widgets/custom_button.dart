import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.width,
    this.height = 56,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? (isPrimary ? AppColors.primaryColor : Colors.white);
    final fgColor = foregroundColor ?? (isPrimary ? Colors.white : AppColors.primaryColor);
    final borderColor = isPrimary ? null : AppColors.primaryColor;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isPrimary
            ? const LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isPrimary ? bgColor : null,
        border: !isPrimary
            ? Border.all(
                color: borderColor ?? AppColors.primaryColor,
                width: 2,
              )
            : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                  spreadRadius: 4,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: fgColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: fgColor,
                          letterSpacing: 0.5,
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