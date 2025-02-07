import 'package:flutter/material.dart';

class AppColors {
  static final light = LightColors();
  static final dark = DarkColors();
}

class LightColors {
  // Основные цвета в стиле Apple Light
  final primary = const Color.fromARGB(255, 255, 255, 255); // iOS синий
  final background = const Color(0xFFF2F2F7); // iOS светлый фон
  final cardBackground = Colors.white;
  final textPrimary = const Color(0xFF000000); // Чёрный текст
  final textSecondary = const Color(0xFF8E8E93); // Серый текст
  final divider = const Color(0xFFC6C6C8); // Разделитель
}

class DarkColors {
  // Основные цвета в стиле Apple Dark
  final primary = const Color(0xFF0A84FF); // iOS тёмно-синий
  final background = const Color(0xFF000000); // Чёрный фон
  final cardBackground = const Color(0xFF1C1C1E); // Тёмные карточки
  final textPrimary = Colors.white; // Белый текст
  final textSecondary = const Color(0xFF8E8E93); // Серый текст
  final divider = const Color(0xFF38383A); // Тёмный разделитель
}
