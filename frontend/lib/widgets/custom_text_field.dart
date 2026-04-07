import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool isBold;
  final double fontSize;
  final Color? color;

  const CustomText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.isBold = false,
    this.fontSize = 14,
    this.color,
  }) : super(key: key);

  // Factory constructors for common text styles
  factory CustomText.heading(
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int? maxLines,
  }) =>
      CustomText(
        text,
        style: AppTextStyles.headingMedium.copyWith(
          color: color ?? AppColors.textDark,
        ),
        fontSize: 28,
        textAlign: textAlign,
        maxLines: maxLines,
      );

  factory CustomText.title(
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int? maxLines,
  }) =>
      CustomText(
        text,
        style: AppTextStyles.bodyLarge.copyWith(
          color: color ?? AppColors.textDark,
          fontWeight: FontWeight.w700,
        ),
        fontSize: 18,
        textAlign: textAlign,
        maxLines: maxLines,
      );

  factory CustomText.body(
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int? maxLines,
  }) =>
      CustomText(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color ?? AppColors.textDark,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
      );

  factory CustomText.subtitle(
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int? maxLines,
  }) =>
      CustomText(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color ?? AppColors.textLight,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
      );

  factory CustomText.caption(
    String text, {
    Color? color,
    TextAlign textAlign = TextAlign.left,
    int? maxLines,
  }) =>
      CustomText(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color ?? AppColors.textMuted,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
      );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ??
          TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color ?? AppColors.textDark,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}