import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF2563EB);      // Blue
  static const secondaryColor = Color(0xFF7C3AED);    // Purple
  static const accentColor = Color(0xFF06B6D4);       // Cyan
  static const backgroundColor = Color(0xFFF8FAFC);   // Light Gray
  static const surfaceColor = Color(0xFFFFFFFF);      // White
  static const errorColor = Color(0xFFDC2626);        // Red
  static const successColor = Color(0xFF059669);      // Green
  static const warningColor = Color(0xFFF59E0B);      // Amber
  static const textDark = Color(0xFF1F2937);          // Dark Gray
  static const textLight = Color(0xFF6B7280);         // Light Gray
  static const borderColor = Color(0xFFE5E7EB);       // Border Gray
  static const shadowColor = Color(0x1F000000);       // Shadow

  // Gradient colors
  static const gradientStart = primaryColor;
  static const gradientEnd = secondaryColor;
}

// Text Styles
class AppTextStyles {
  static const headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );

  static const headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  static const headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: -0.2,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.surfaceColor,
    letterSpacing: 0.3,
  );
}

// App Theme
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      surface: AppColors.surfaceColor,
      error: AppColors.errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceColor,
      elevation: 0.0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.headingSmall,
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceColor,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderColor, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      labelStyle: AppTextStyles.bodyMedium,
      hintStyle: AppTextStyles.bodyMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.surfaceColor,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}