import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'dart:io';

/// Кнопка с микроинтеракциями
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enableHapticFeedback;
  final double scaleOnPress;

  const AnimatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.enableHapticFeedback = true,
    this.scaleOnPress = 0.95,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
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
      end: widget.scaleOnPress,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
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
    if (widget.enableHapticFeedback && widget.enabled) {
      if (await Haptics.canVibrate()) {
        if (Platform.isIOS) {
          await Haptics.vibrate(HapticsType.light);
        }
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
    _triggerHaptic();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    if (widget.onPressed != null) {
      Future.delayed(const Duration(milliseconds: 100), widget.onPressed!);
    }
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = widget.backgroundColor ?? colorScheme.primary;
    final foregroundColor = widget.foregroundColor ?? colorScheme.onPrimary;

    return GestureDetector(
      onTapDown: widget.enabled ? _handleTapDown : null,
      onTapUp: widget.enabled ? _handleTapUp : null,
      onTapCancel: widget.enabled ? _handleTapCancel : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.enabled ? _opacityAnimation.value : 0.5,
              child: Container(
                padding: widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                  boxShadow: widget.enabled && _isPressed
                      ? [
                          BoxShadow(
                            color: backgroundColor.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: backgroundColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: DefaultTextStyle(
                  style: TextStyle(color: foregroundColor),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
