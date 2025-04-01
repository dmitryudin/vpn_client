import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true, // Включаем Material Design 3
      colorScheme: ColorScheme.light(
        primary: AppColors.light.primary,
        secondary: AppColors.light.accent,
        surface: AppColors.light.cardBackground,
        background: AppColors.light.background,
        onPrimary: AppColors.light.textPrimary,
        onSecondary: AppColors.light.textPrimary,
        onSurface: AppColors.light.textPrimary,
        onBackground: AppColors.light.textPrimary,
        error: AppColors.light.error,
      ),
      scaffoldBackgroundColor: AppColors.light.background,
      cardColor: AppColors.light.cardBackground,
      dividerColor: AppColors.light.divider,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'Helvetica',
        ),
        bodyMedium: TextStyle(
          color: AppColors.light.textSecondary,
          fontFamily: 'Helvetica',
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.light.primary,
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
        backgroundColor: AppColors.light.accent,
        foregroundColor: AppColors.light.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.light.accent,
          foregroundColor: AppColors.light.textPrimary,
          textStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.bold,
          ),
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
        secondary: AppColors.dark.accent,
        surface: AppColors.dark.cardBackground,
        background: AppColors.dark.background,
        onPrimary: AppColors.dark.textPrimary,
        onSecondary: AppColors.dark.textPrimary,
        onSurface: AppColors.dark.textPrimary,
        onBackground: AppColors.dark.textPrimary,
        error: AppColors.dark.error,
      ),
      scaffoldBackgroundColor: AppColors.dark.background,
      cardColor: AppColors.dark.cardBackground,
      dividerColor: AppColors.dark.divider,
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'Helvetica',
        ),
        bodyMedium: TextStyle(
          color: AppColors.dark.textSecondary,
          fontFamily: 'Helvetica',
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark.primary,
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
        backgroundColor: AppColors.dark.accent,
        foregroundColor: AppColors.dark.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark.accent,
          foregroundColor: AppColors.dark.textPrimary,
          textStyle: TextStyle(
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
