import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/error/app_snackbar_widget.dart';
import 'dart:developer' as dev;

void showErrorSnackbar(
  BuildContext context,
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  if (error != null) {
    dev.log(
      '[Snackbar Error] $message\n$error${stackTrace != null ? '\n$stackTrace' : ''}',
    );
  }
  _show(context, message, AppSnackbarVariant.error);
}

void showInfoSnackbar(BuildContext context, String message) {
  _show(context, message, AppSnackbarVariant.info);
}

void _show(BuildContext context, String message, AppSnackbarVariant variant) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      duration: const Duration(milliseconds: 4000),
      content: Builder(
        builder: (innerContext) => AppSnackbarContent(
          message: message,
          variant: variant,
          onDismiss: () =>
              ScaffoldMessenger.of(innerContext).hideCurrentSnackBar(),
        ),
      ),
    ),
  );
}
