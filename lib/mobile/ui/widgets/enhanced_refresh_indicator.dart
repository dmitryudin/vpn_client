import 'package:flutter/material.dart';

class EnhancedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const EnhancedRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final refreshColor = color ?? colorScheme.primary;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: refreshColor,
      backgroundColor: colorScheme.surface,
      strokeWidth: 3,
      displacement: 40,
      child: child,
    );
  }
}
