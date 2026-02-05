import 'package:flutter/material.dart';

/// Skeleton loader с shimmer эффектом
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseColor = widget.baseColor ??
        (theme.brightness == Brightness.dark
            ? colorScheme.surfaceVariant.withOpacity(0.3)
            : colorScheme.surfaceVariant.withOpacity(0.5));
    final highlightColor = widget.highlightColor ??
        (theme.brightness == Brightness.dark
            ? colorScheme.surfaceVariant.withOpacity(0.5)
            : colorScheme.surfaceVariant.withOpacity(0.8));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                baseColor,
                highlightColor,
                baseColor,
                baseColor,
              ],
              stops: [
                0.0,
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton для карточки сервера
class ServerCardSkeleton extends StatelessWidget {
  const ServerCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          SkeletonLoader(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.circular(28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: double.infinity, height: 20),
                const SizedBox(height: 8),
                SkeletonLoader(width: 120, height: 14),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SkeletonLoader(width: 24, height: 24, borderRadius: BorderRadius.circular(12)),
        ],
      ),
    );
  }
}

/// Skeleton для карточки статистики
class StatisticsCardSkeleton extends StatelessWidget {
  const StatisticsCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(width: 24, height: 24, borderRadius: BorderRadius.circular(6)),
              const SizedBox(width: 12),
              SkeletonLoader(width: 150, height: 20),
            ],
          ),
          const SizedBox(height: 24),
          SkeletonLoader(width: double.infinity, height: 60, borderRadius: BorderRadius.circular(12)),
          const SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 60, borderRadius: BorderRadius.circular(12)),
        ],
      ),
    );
  }
}
