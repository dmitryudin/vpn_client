import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'dart:io';

enum ToastType { success, error, info, warning }

class EnhancedToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static Future<void> show(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
    bool enableHaptic = true,
  }) async {
    if (_isVisible) {
      hide();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (enableHaptic) {
      await _triggerHaptic(type);
    }

    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry(context, message, type, duration);
    overlay.insert(_overlayEntry!);
    _isVisible = true;

    Future.delayed(duration + const Duration(milliseconds: 300), () {
      hide();
    });
  }

  static void hide() {
    if (_overlayEntry != null && _isVisible) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isVisible = false;
    }
  }

  static OverlayEntry _createOverlayEntry(
    BuildContext context,
    String message,
    ToastType type,
    Duration duration,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
        iconColor = Colors.white;
        break;
      case ToastType.error:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        icon = Icons.error_rounded;
        iconColor = colorScheme.onError;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.warning_rounded;
        iconColor = Colors.white;
        break;
      case ToastType.info:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        icon = Icons.info_rounded;
        iconColor = colorScheme.onPrimary;
        break;
    }

    return OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        icon: icon,
        iconColor: iconColor,
        duration: duration,
      ),
    );
  }

  static Future<void> _triggerHaptic(ToastType type) async {
    if (await Haptics.canVibrate()) {
      if (Platform.isIOS) {
        switch (type) {
          case ToastType.success:
            await Haptics.vibrate(HapticsType.success);
            break;
          case ToastType.error:
            await Haptics.vibrate(HapticsType.error);
            break;
          default:
            await Haptics.vibrate(HapticsType.light);
        }
      }
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          EnhancedToast.hide();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
