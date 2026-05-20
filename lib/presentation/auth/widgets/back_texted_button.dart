import 'package:flutter/material.dart';

class BackTextedButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BackTextedButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface.withAlpha(179),
          backgroundColor: colorScheme.surfaceContainerHigh,
        ),
        onPressed: onPressed,
        icon: Icon(
          Icons.arrow_back,
          color: colorScheme.onSurface.withAlpha(179),
        ),
        label: Text(
          'Back',
          style: TextStyle(
            color: colorScheme.onSurface.withAlpha(179),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
