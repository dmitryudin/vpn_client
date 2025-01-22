import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.light.primary,
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
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.dark.primary,
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
    );
  }
}
