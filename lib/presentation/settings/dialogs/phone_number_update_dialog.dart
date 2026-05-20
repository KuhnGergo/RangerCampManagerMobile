import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/phone_number_input_field.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

void showPhoneNumberUpdateDialog({
  required BuildContext context,
  BuildContext? errorContext,
  String? initialValue,
  required Future<void> Function(String?) confirmAction,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PhoneNumberUpdateDialog(
      errorContext: errorContext ?? context,
      initialValue: initialValue,
      confirmAction: confirmAction,
    ),
  );
}

class _PhoneNumberUpdateDialog extends StatefulWidget {
  final BuildContext errorContext;
  final String? initialValue;
  final Future<void> Function(String?) confirmAction;

  const _PhoneNumberUpdateDialog({
    required this.errorContext,
    this.initialValue,
    required this.confirmAction,
  });

  @override
  State<_PhoneNumberUpdateDialog> createState() =>
      _PhoneNumberUpdateDialogState();
}

class _PhoneNumberUpdateDialogState extends State<_PhoneNumberUpdateDialog> {
  String? _phoneNumber;
  bool _isPhoneValid = true;
  String? _errorText;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue?.trim();
    _phoneNumber = (initial == null || initial.isEmpty) ? null : initial;
  }

  Future<void> _onConfirm() async {
    if (_phoneNumber != null && !_isPhoneValid) {
      setState(() => _errorText = 'Please enter a valid phone number');
      return;
    }

    setState(() {
      _isUpdating = true;
      _errorText = null;
    });

    try {
      await widget.confirmAction(_phoneNumber);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (widget.errorContext.mounted) {
        showError(
          widget.errorContext,
          'Failed to update phone number',
          extendedText: errorMessage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(
        'Update Phone Number',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: PhoneNumberInputField(
          labelText: 'Phone Number',
          hintText: 'Enter phone number',
          initialValue: widget.initialValue,
          enabled: !_isUpdating,
          autofocus: true,
          errorText: _errorText,
          onChanged: (value) {
            setState(() {
              _phoneNumber = value;
              if (_errorText != null) _errorText = null;
            });
          },
          onValidationChanged: (isValid) {
            setState(() {
              _isPhoneValid = isValid;
              if (_errorText != null && (_phoneNumber == null || isValid)) {
                _errorText = null;
              }
            });
          },
          onSubmitted: (_) => _onConfirm(),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
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
