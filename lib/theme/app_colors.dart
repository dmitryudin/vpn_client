import 'package:flutter/material.dart';

class AppColors {
  static final light = _LightColors();
  static final dark = _DarkColors();
}

class _LightColors {
  // Основные цвета
  final primary = const Color(0xFF2C5364);
  final secondary = const Color(0xFF4A90E2);
  final background = const Color(0xFFF5F7FA);

  // Текст
  final textPrimary = const Color(0xFF2C3E50);
  final textSecondary = const Color(0xFF7F8C8D);

  // Компоненты
  final cardBackground = Colors.white;
  final buttonPrimary = const Color(0xFF2C5364);
  final divider = const Color(0xFFE0E6ED);
}

class _DarkColors {
  // Основные цвета
  final primary = const Color(0xFF1E3A5F);
  final secondary = const Color(0xFF4A90E2);
  final background = const Color(0xFF121212);

  // Текст
  final textPrimary = Colors.white;
  final textSecondary = const Color(0xFFB2B2B2);

  // Компоненты
  final cardBackground = const Color(0xFF2C2C2C);
  final buttonPrimary = const Color(0xFF344966);
  final divider = const Color(0xFF3A3A3A);
}
