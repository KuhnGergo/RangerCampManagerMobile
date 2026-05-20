import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/api/api.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

void showTextUpdateDialog({
  required BuildContext context,
  BuildContext? errorContext,
  required String title,
  required String label,
  required String genericErrorMessage,
  String? initialValue,
  String? hintText,
  String? informationText,
  String? Function(String)? validator,
  required Future<void> Function(String) confirmAction,
  int maxLength = 50,
  String? notFoundMessage,
  String? badRequestMessage,
  TextCapitalization textCapitalization = TextCapitalization.none,
  bool autocorrect = true,
  bool enableSuggestions = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TextUpdateDialog(
      title: title,
      label: label,
      errorContext: errorContext ?? context,
      initialValue: initialValue,
      hintText: hintText,
      informationText: informationText,
      genericErrorMessage: genericErrorMessage,
      validator: validator,
      confirmAction: confirmAction,
      maxLength: maxLength,
      notFoundMessage: notFoundMessage,
      badRequestMessage: badRequestMessage,
      textCapitalization: textCapitalization,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
    ),
  );
}

class _TextUpdateDialog extends StatefulWidget {
  final String title;
  final String label;
  final BuildContext errorContext;
  final String? initialValue;
  final String? hintText;
  final String? informationText;
  final String genericErrorMessage;
  final String? Function(String)? validator;
  final Future<void> Function(String) confirmAction;
  final int maxLength;
  final String? notFoundMessage;
  final String? badRequestMessage;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;

  const _TextUpdateDialog({
    required this.title,
    required this.label,
    required this.errorContext,
    required this.genericErrorMessage,
    this.initialValue,
    this.hintText,
    this.informationText,
    this.validator,
    required this.confirmAction,
    required this.maxLength,
    this.notFoundMessage,
    this.badRequestMessage,
    required this.textCapitalization,
    required this.autocorrect,
    required this.enableSuggestions,
  });

  @override
  State<_TextUpdateDialog> createState() => _TextUpdateDialogState();
}

class _TextUpdateDialogState extends State<_TextUpdateDialog> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final value = _controller.text.trim();
    final validationError = widget.validator?.call(value);
    if (validationError != null) {
      setState(() => _errorText = validationError);
      return;
    }
    setState(() {
      _isUpdating = true;
      _errorText = null;
    });
    try {
      await widget.confirmAction(value);
      if (mounted) Navigator.of(context).pop();
    } on NotFoundException catch (_) {
      setState(() {
        _errorText = widget.notFoundMessage ?? 'Item not found';
      });
    } on BadRequestException catch (_) {
      setState(() {
        _errorText =
            widget.badRequestMessage ??
            'Not a valid ${widget.label.toLowerCase()}';
      });
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (widget.errorContext.mounted) {
        showError(
          widget.errorContext,
          widget.genericErrorMessage,
          extendedText: errorMessage,
        );
      } else if (mounted) {
        showError(
          context,
          widget.genericErrorMessage,
          extendedText: errorMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeData = Theme.of(context);

    return AlertDialog(
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.informationText != null &&
              widget.informationText!.isNotEmpty)
            Text(
              widget.informationText!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withAlpha(160),
                fontSize: 14,
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextField(
              controller: _controller,
              enabled: !_isUpdating,
              autofocus: true,
              textCapitalization: widget.textCapitalization,
              autocorrect: widget.autocorrect,
              enableSuggestions: widget.enableSuggestions,
              maxLength: widget.maxLength,
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
              onSubmitted: (_) => _onConfirm(),
              decoration: getFormFieldDecoration(
                labelText: widget.label,
                hintText: widget.hintText,
                themeData: themeData,
                errorText: _errorText,
                enabled: !_isUpdating,
              ),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isUpdating ? null : _onConfirm,
          child: _isUpdating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: ThreeDotLoadingIndicator(
                    dotSize: 2.5,
                    orbitRadius: 7,
                    spinDuration: Duration(seconds: 1),
                    color: colorScheme.onPrimary,
                  ),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }
}
