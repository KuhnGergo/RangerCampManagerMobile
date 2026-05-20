import 'package:flutter/material.dart';

class ChatActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ChatActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useBackgroundColor = backgroundColor ?? colorScheme.primary;
    final useForegroundColor = foregroundColor ?? colorScheme.onPrimary;

    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        foregroundColor: useForegroundColor,
        backgroundColor: useBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
