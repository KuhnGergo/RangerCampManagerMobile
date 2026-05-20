import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/error/app_snackbar.dart';

/// Forwards to [showErrorSnackbar]. Kept for compatibility with existing call sites.
void showError(
  BuildContext context,
  String message, {
  String? extendedText,
  bool replaceExisting = true,
  StackTrace? stackTrace,
}) {
  showErrorSnackbar(
    context,
    message,
    error: extendedText,
    stackTrace: stackTrace,
  );
}
