import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

void showWarningDialog({
  required BuildContext context,
  required String title,
  required String secondThoughtLabel,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  required Future<void> Function() confirmAction,
  VoidCallback? onConfirmed,
  required String genericErrorMessage,
  Color? titleColor,
  Color? buttonColor,
  Color? buttonForegroundColor,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _WarningDialog(
      title: title,
      secondThoughtLabel: secondThoughtLabel,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmAction: confirmAction,
      onConfirmed: onConfirmed,
      genericErrorMessage: genericErrorMessage,
      titleColor: titleColor,
      buttonColor: buttonColor,
      buttonForegroundColor: buttonForegroundColor,
    ),
  );
}

class _WarningDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final String secondThoughtLabel;
  final Future<void> Function() confirmAction;
  final VoidCallback? onConfirmed;
  final String genericErrorMessage;
  final Color? titleColor;
  final Color? buttonColor;
  final Color? buttonForegroundColor;

  const _WarningDialog({
    required this.title,
    required this.secondThoughtLabel,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmAction,
    this.onConfirmed,
    required this.genericErrorMessage,
    this.titleColor,
    this.buttonColor,
    this.buttonForegroundColor,
  });

  @override
  State<_WarningDialog> createState() => _WarningDialogState();
}

class _WarningDialogState extends State<_WarningDialog> {
  bool _isExecuting = false;

  Future<void> _onConfirm() async {
    setState(() => _isExecuting = true);
    try {
      await widget.confirmAction();
      if (mounted) {
        Navigator.of(context).pop();
        widget.onConfirmed?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isExecuting = false);
        showError(
          context,
          widget.genericErrorMessage,
          extendedText: e.toString().replaceAll('Exception: ', ''),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveTitleColor = widget.titleColor ?? colorScheme.error;
    final effectiveButtonColor = widget.buttonColor ?? colorScheme.error;
    final effectiveButtonForegroundColor =
        widget.buttonForegroundColor ?? colorScheme.onError;

    return AlertDialog(
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: effectiveTitleColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.secondThoughtLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            widget.cancelLabel,
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
        FilledButton(
          onPressed: _isExecuting ? null : _onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: effectiveButtonColor,
            foregroundColor: effectiveButtonForegroundColor,
          ),
          child: _isExecuting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: ThreeDotLoadingIndicator(
                    dotSize: 2.5,
                    orbitRadius: 7,
                    spinDuration: Duration(seconds: 1),
                    color: effectiveButtonForegroundColor,
                  ),
                )
              : Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
