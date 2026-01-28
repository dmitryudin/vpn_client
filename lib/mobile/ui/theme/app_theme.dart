import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true, // Включаем Material Design 3
      colorScheme: ColorScheme.light(
        primary: AppColors.light.primary,
        onPrimary: AppColors.light.onPrimary,
        primaryContainer: AppColors.light.primaryContainer,
        onPrimaryContainer: AppColors.light.primary,
        secondary: AppColors.light.secondary,
        onSecondary: AppColors.light.onSecondary,
        secondaryContainer: AppColors.light.secondaryContainer,
        onSecondaryContainer: AppColors.light.secondary,
        surface: AppColors.light.surface,
        onSurface: AppColors.light.onSurface,
        surfaceVariant: AppColors.light.surfaceVariant,
        onSurfaceVariant: AppColors.light.textSecondary,
        background: AppColors.light.background,
        onBackground: AppColors.light.onBackground,
        error: AppColors.light.error,
        onError: Colors.white,
        errorContainer: const Color(0xFFFFEBEE),
        onErrorContainer: AppColors.light.error,
      ),
      scaffoldBackgroundColor: AppColors.light.background,
      cardColor: AppColors.light.cardBackground,
      dividerColor: AppColors.light.divider,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
        ),
        bodyMedium: TextStyle(
          color: AppColors.light.textSecondary,
          fontFamily: 'Helvetica',
        ),
        bodySmall: TextStyle(
          color: AppColors.light.textTertiary,
          fontFamily: 'Helvetica',
        ),
        labelLarge: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: AppColors.light.textSecondary,
          fontFamily: 'Helvetica',
        ),
        labelSmall: TextStyle(
          color: AppColors.light.textTertiary,
          fontFamily: 'Helvetica',
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.light.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: AppColors.light.textPrimary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.light.primary,
        foregroundColor: AppColors.light.onPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.light.primary,
          foregroundColor: AppColors.light.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.light.primary,
          side: BorderSide(color: AppColors.light.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.light.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.light.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.light.divider.withOpacity(0.2), width: 1),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true, // Включаем Material Design 3
      colorScheme: ColorScheme.dark(
        primary: AppColors.dark.primary,
        onPrimary: AppColors.dark.onPrimary,
        primaryContainer: AppColors.dark.primaryContainer,
        onPrimaryContainer: AppColors.dark.primary,
        secondary: AppColors.dark.secondary,
        onSecondary: AppColors.dark.onSecondary,
        secondaryContainer: AppColors.dark.secondaryContainer,
        onSecondaryContainer: AppColors.dark.secondary,
        surface: AppColors.dark.surface,
        onSurface: AppColors.dark.onSurface,
        surfaceVariant: AppColors.dark.surfaceVariant,
        onSurfaceVariant: AppColors.dark.textSecondary,
        background: AppColors.dark.background,
        onBackground: AppColors.dark.onBackground,
        error: AppColors.dark.error,
        onError: Colors.white,
        errorContainer: const Color(0xFF3F1F1F),
        onErrorContainer: AppColors.dark.error,
      ),
      scaffoldBackgroundColor: AppColors.dark.background,
      cardColor: AppColors.dark.cardBackground,
      dividerColor: AppColors.dark.divider,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
        ),
        bodyMedium: TextStyle(
          color: AppColors.dark.textSecondary,
          fontFamily: 'Helvetica',
        ),
        bodySmall: TextStyle(
          color: AppColors.dark.textTertiary,
          fontFamily: 'Helvetica',
        ),
        labelLarge: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: AppColors.dark.textSecondary,
          fontFamily: 'Helvetica',
        ),
        labelSmall: TextStyle(
          color: AppColors.dark.textTertiary,
          fontFamily: 'Helvetica',
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: AppColors.dark.textPrimary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.dark.primary,
        foregroundColor: AppColors.dark.onPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark.primary,
          foregroundColor: AppColors.dark.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dark.primary,
          side: BorderSide(color: AppColors.dark.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.dark.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.dark.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.dark.divider.withOpacity(0.3), width: 1),
        ),
      ),
    );
  }
}
