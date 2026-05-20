import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/snackbar/app_snackbar.dart';

class AppMessage {
  static void showSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required BuildContext context,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        appSnackbar(
          message: message,
          backgroundColor: backgroundColor,
          icon: icon,
          context: context,
        ),
      );
  }
}
