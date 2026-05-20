import 'package:flutter/material.dart';

enum AppSnackbarVariant { error, info }

class AppSnackbarContent extends StatelessWidget {
  final String message;
  final AppSnackbarVariant variant;
  final VoidCallback onDismiss;

  const AppSnackbarContent({
    super.key,
    required this.message,
    required this.variant,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (bg, fg, icon) = switch (variant) {
      AppSnackbarVariant.error => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        Icons.error_outline_rounded,
      ),
      AppSnackbarVariant.info => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
        Icons.info_outline_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                if (variant == AppSnackbarVariant.error)
                  Text(
                    'Please try again later.',
                    style: TextStyle(
                      color: fg.withAlpha(180),
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              color: fg.withAlpha(180),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
