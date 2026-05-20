import 'package:flutter/material.dart';

SnackBar appSnackbar({
  required String message,
  required Color backgroundColor,
  required IconData icon,
  required BuildContext context,
}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: backgroundColor,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    content: Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          icon: Icon(Icons.close, color: Colors.white),
        ),
      ],
    ),
  );
}
