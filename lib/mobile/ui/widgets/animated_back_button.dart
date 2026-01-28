import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Универсальная анимированная кнопка назад с переворачиванием стрелочки
class AnimatedBackButton extends StatefulWidget {
  final Color? iconColor;
  final VoidCallback? onPressed;
  
  const AnimatedBackButton({
    Key? key,
    this.iconColor,
    this.onPressed,
  }) : super(key: key);

  @override
  State<AnimatedBackButton> createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<AnimatedBackButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = widget.iconColor ?? colorScheme.onSurface;

    return IconButton(
      icon: AnimatedRotation(
        duration: const Duration(milliseconds: 300),
        turns: _isExpanded ? 0.5 : 0,
        child: Icon(
          Icons.keyboard_arrow_down_outlined,
          color: iconColor,
        ),
      ),
      onPressed: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        if (widget.onPressed != null) {
          widget.onPressed!();
        } else {
          context.pop();
        }
      },
    );
  }
}
