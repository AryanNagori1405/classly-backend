import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Blue Gradient
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E40AF);

  // Accent Colors
  static const Color accentColor = Color(0xFF10B981);
  static const Color accentLight = Color(0xFF34D399);

  // Text Colors
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFD1D5DB);

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
  
  // Additional colors
  static const Color infoColor = Color(0xFF06B6D4);
  static const Color linkColor = Color(0xFF2563EB);
}

class AppTextStyles {
  static const String fontFamily = 'Poppins';

  // Heading Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.4,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // Caption Styles
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // Button Styles
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.5,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      
      // Colors
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.backgroundColor,
      canvasColor: AppColors.surfaceColor,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceColor,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headingLarge,
        displayMedium: AppTextStyles.headingMedium,
        displaySmall: AppTextStyles.headingSmall,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        titleLarge: AppTextStyles.bodyLarge,
        titleMedium: AppTextStyles.bodyMedium,
        titleSmall: AppTextStyles.bodySmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.caption,
        labelSmall: AppTextStyles.caption,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 8,
          shadowColor: AppColors.primaryColor.withOpacity(0.4),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 2,
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
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFB3B3B3),
          fontSize: 14,
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return AppColors.primaryColor;
          }
          return Colors.grey.shade400;
        }),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1.2),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 0,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryColor,
        size: 24,
      ),
    );
  }
}

// Premium Shadows
class AppShadows {
  // Subtle Shadow (elevation 2)
  static BoxShadow get subtle => BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 4,
        offset: const Offset(0, 2),
      );

  // Medium Shadow (elevation 6)
  static BoxShadow get medium => BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

  // Large Shadow (elevation 12)
  static BoxShadow get large => BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 24,
        offset: const Offset(0, 8),
      );

  // Colored Shadow (for primary color)
  static BoxShadow get primaryGlow => BoxShadow(
        color: AppColors.primaryColor.withOpacity(0.25),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      );

  // List of all shadows for layered effect
  static List<BoxShadow> get layered => [
        subtle,
        medium,
      ];
}

// Gradients
class AppGradients {
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [
          AppColors.primaryColor,
          AppColors.primaryLight,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => const LinearGradient(
        colors: [
          AppColors.accentColor,
          AppColors.accentLight,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get purpleGradient => const LinearGradient(
        colors: [
          Color(0xFF8B5CF6),
          Color(0xFFEC4899),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get orangeGradient => const LinearGradient(
        colors: [
          Color(0xFFF59E0B),
          Color(0xFFEA580C),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}