import 'package:flutter/material.dart';

class AppColors {
  static final light = _LightColors();
  static final dark = _DarkColors();
}

class _LightColors {
  final primary = const Color(0xFF007AFF); // iOS blue
  final background = const Color(0xFFF2F2F7); // iOS light background
  final cardBackground = Colors.white;
  final textPrimary = const Color(0xFF000000);
  final textSecondary = const Color(0xFF8E8E93);
  final divider = const Color(0xFFC6C6C8);
}

class _DarkColors {
  final primary = const Color(0xFF0A84FF); // iOS dark mode blue
  final background = const Color(0xFF000000);
  final cardBackground = const Color(0xFF1C1C1E);
  final textPrimary = Colors.white;
  final textSecondary = const Color(0xFF8E8E93);
  final divider = const Color(0xFF38383A);
}
