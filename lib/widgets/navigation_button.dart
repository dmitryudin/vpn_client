import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  NavigationButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
