import 'package:flutter/material.dart';

class AppColors {
  static final light = LightColors();
  static final dark = DarkColors();
}

class LightColors {
  // Основные цвета для светлой темы (улучшенная палитра с правильным контрастом)
  final primary = const Color(0xFF007AFF); // Акцентный синий (iOS стиль) - основной цвет
  final primaryContainer = const Color(0xFFE3F2FD); // Светло-синий контейнер
  final secondary = const Color(0xFF5856D6); // Вторичный фиолетовый
  final secondaryContainer = const Color(0xFFE8E5FF); // Светло-фиолетовый контейнер
  final background = const Color(0xFFF5F5F5); // Светло-серый фон
  final surface = const Color(0xFFFFFFFF); // Белый фон для карточек
  final surfaceVariant = const Color(0xFFF9F9F9); // Вариант поверхности
  final cardBackground = const Color(0xFFFFFFFF); // Белый фон для карточек
  final textPrimary = const Color(0xFF000000); // Чёрный текст
  final textSecondary = const Color(0xFF8E8E93); // Серый текст
  final textTertiary = const Color(0xFFC7C7CC); // Третичный серый текст
  final divider = const Color(0xFFC6C6C8); // Разделитель
  final accent = const Color(0xFF007AFF); // Акцентный синий (iOS стиль)
  final success = const Color(0xFF34C759); // Зелёный для успеха
  final error = const Color(0xFFFF3B30); // Красный для ошибок
  final warning = const Color(0xFFFF9500); // Оранжевый для предупреждений
  final onPrimary = const Color(0xFFFFFFFF); // Белый текст на primary
  final onSecondary = const Color(0xFFFFFFFF); // Белый текст на secondary
  final onSurface = const Color(0xFF000000); // Чёрный текст на surface
  final onBackground = const Color(0xFF000000); // Чёрный текст на background
}

class DarkColors {
  // Основные цвета для тёмной темы (улучшенная палитра с правильным контрастом)
  final primary = const Color(0xFF0A84FF); // Яркий синий (iOS стиль) - основной цвет
  final primaryContainer = const Color(0xFF1A3A5C); // Тёмно-синий контейнер
  final secondary = const Color(0xFF5E5CE6); // Вторичный фиолетовый
  final secondaryContainer = const Color(0xFF2D2B5C); // Тёмно-фиолетовый контейнер
  final background = const Color(0xFF000000); // Чёрный фон
  final surface = const Color(0xFF1C1C1E); // Тёмный фон для карточек
  final surfaceVariant = const Color(0xFF2C2C2E); // Вариант поверхности
  final cardBackground = const Color(0xFF1C1C1E); // Тёмный фон для карточек
  final textPrimary = const Color(0xFFFFFFFF); // Белый текст
  final textSecondary = const Color(0xFF8E8E93); // Серый текст
  final textTertiary = const Color(0xFF636366); // Третичный серый текст
  final divider = const Color(0xFF38383A); // Тёмный разделитель
  final accent = const Color(0xFF0A84FF); // Акцентный синий (iOS стиль)
  final success = const Color(0xFF32D74B); // Зелёный для успеха
  final error = const Color(0xFFFF453A); // Красный для ошибок
  final warning = const Color(0xFFFF9F0A); // Оранжевый для предупреждений
  final onPrimary = const Color(0xFFFFFFFF); // Белый текст на primary
  final onSecondary = const Color(0xFFFFFFFF); // Белый текст на secondary
  final onSurface = const Color(0xFFFFFFFF); // Белый текст на surface
  final onBackground = const Color(0xFFFFFFFF); // Белый текст на background
}
