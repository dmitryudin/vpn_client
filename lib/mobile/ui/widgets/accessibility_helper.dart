import 'package:flutter/material.dart';

/// Helper для accessibility улучшений
class AccessibilityHelper {
  /// Создает семантический контейнер с правильными метками
  static Widget semanticButton({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      child: child,
      onTap: onTap,
    );
  }

  /// Создает семантический контейнер для карточки
  static Widget semanticCard({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      child: child,
    );
  }

  /// Улучшенный размер touch target (минимум 44x44 для iOS)
  static double get minTouchTargetSize => 44.0;

  /// Создает контейнер с минимальным размером touch target
  static Widget touchTarget({
    required Widget child,
    VoidCallback? onTap,
    double? minSize,
  }) {
    final size = minSize ?? minTouchTargetSize;
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
