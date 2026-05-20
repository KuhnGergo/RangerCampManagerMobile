import 'package:currency_formatter/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/api/api.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

void showChangePaymentCurrencyDialog({
  required BuildContext context,
  BuildContext? errorContext,
  required String title,
  required String genericErrorMessage,
  required String initialCurrency,
  required Future<void> Function(String) confirmAction,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ChangePaymentCurrencyDialog(
      title: title,
      errorContext: errorContext ?? context,
      initialCurrency: initialCurrency,
      genericErrorMessage: genericErrorMessage,
      confirmAction: confirmAction,
    ),
  );
}

class _ChangePaymentCurrencyDialog extends StatefulWidget {
  final String title;
  final BuildContext errorContext;
  final String initialCurrency;
  final String genericErrorMessage;
  final Future<void> Function(String) confirmAction;

  const _ChangePaymentCurrencyDialog({
    required this.title,
    required this.errorContext,
    required this.initialCurrency,
    required this.genericErrorMessage,
    required this.confirmAction,
  });

  @override
  State<_ChangePaymentCurrencyDialog> createState() =>
      _ChangePaymentCurrencyDialogState();
}

class _ChangePaymentCurrencyDialogState
    extends State<_ChangePaymentCurrencyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final List<CurrencyFormat> _currencies;

  String? _currency;
  String? _currencyError;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currencies = CurrencyFormatter.majorsList;

    final normalizedInitialCurrency = widget.initialCurrency.toUpperCase();
    final isSupported = _currencies.any(
      (currency) => currency.code?.toUpperCase() == normalizedInitialCurrency,
    );

    _currency = isSupported
        ? normalizedInitialCurrency
        : CurrencyFormatter.majorsList.first.code!.toUpperCase();
  }

  Future<void> _onConfirm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currency == null) {
      setState(() {
        _currencyError = 'Please select a currency';
      });
      return;
    }

    setState(() {
      _isUpdating = true;
      _currencyError = null;
    });

    try {
      await widget.confirmAction(_currency!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }

      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (e is BadRequestException) {
        setState(() {
          _currencyError = 'Unsupported currency code';
        });
      } else if (widget.errorContext.mounted) {
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
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: getFormFieldDecoration(
                labelText: 'Currency',
                themeData: themeData,
                hintText: 'Select currency',
                errorText: _currencyError,
                enabled: !_isUpdating,
              ),
              borderRadius: BorderRadius.circular(20),
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency.code!.toUpperCase(),
                  child: Text(
                    '${currency.symbol} ${currency.code!.toUpperCase()}',
                  ),
                );
              }).toList(),
              onChanged: _isUpdating
                  ? null
                  : (value) {
                      setState(() {
                        _currency = value;
                        _currencyError = null;
                      });
                    },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a currency';
                }

                final exists = _currencies.any(
                  (currency) => currency.code?.toUpperCase() == value,
                );
                if (!exists) {
                  return 'Unsupported currency code';
                }

                return null;
              },
            ),
          ],
        ),
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
