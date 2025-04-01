import 'package:flutter/material.dart';

class AppColors {
  static final light = LightColors();
  static final dark = DarkColors();
}

class LightColors {
  // Основные цвета для светлой темы
  final primary = const Color(0xFFFFFFFF); // Белый
  final background = const Color(0xFFF5F5F5); // Светло-серый фон
  final cardBackground = const Color(0xFFFFFFFF); // Белый фон для карточек
  final textPrimary = const Color(0xFF000000); // Чёрный текст
  final textSecondary = const Color(0xFF8E8E93); // Серый текст
  final divider = const Color(0xFFC6C6C8); // Разделитель
  final accent = const Color(0xFF007AFF); // Акцентный синий (iOS стиль)
  final success = const Color(0xFF34C759); // Зелёный для успеха
  final error = const Color(0xFFFF3B30); // Красный для ошибок
  final warning = const Color(0xFFFF9500); // Оранжевый для предупреждений
}

class DarkColors {
  // Основные цвета для тёмной темы (тёмно-коричневая)
  final primary = const Color(0xFF1E1E1E); // Тёмно-коричневый
  final background = const Color(0xFF121212); // Очень тёмный фон
  final cardBackground = const Color(0xFF2C2C2E); // Тёмный фон для карточек
  final textPrimary = const Color(0xFFFFFFFF); // Белый текст
  final textSecondary = const Color(0xFF8E8E93); // Серый текст
  final divider = const Color(0xFF38383A); // Тёмный разделитель
  final accent = const Color(0xFFD4AF37); // Золотистый акцент (для красоты)
  final success = const Color(0xFF32D74B); // Зелёный для успеха
  final error = const Color(0xFFFF453A); // Красный для ошибок
  final warning = const Color(0xFFFF9F0A); // Оранжевый для предупреждений
}
