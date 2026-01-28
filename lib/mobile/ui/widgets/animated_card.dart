import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'dart:io';

/// Карточка с микроинтеракциями
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final bool enableHapticFeedback;
  final double scaleOnTap;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.enableHapticFeedback = true,
    this.scaleOnTap = 0.98,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleOnTap,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerHaptic() async {
    if (widget.enableHapticFeedback) {
      if (await Haptics.canVibrate()) {
        if (Platform.isIOS) {
          await Haptics.vibrate(HapticsType.light);
        }
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    _triggerHaptic();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    if (widget.onTap != null) {
      Future.delayed(const Duration(milliseconds: 100), widget.onTap!);
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding,
              margin: widget.margin,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? colorScheme.surface,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                boxShadow: widget.boxShadow ??
                    [
                      BoxShadow(
                        color: _isPressed
                            ? colorScheme.primary.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: _isPressed ? 8 : 12,
                        offset: Offset(0, _isPressed ? 2 : 4),
                        spreadRadius: _isPressed ? 0 : 1,
                      ),
                    ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
