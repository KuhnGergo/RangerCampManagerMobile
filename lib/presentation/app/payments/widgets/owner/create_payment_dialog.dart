import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/auth/utils/form_field_style.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/actions/payment_actions_provider.dart';
import 'package:intl/intl.dart';
import 'package:currency_formatter/currency_formatter.dart';

class CreatePaymentDialog extends ConsumerStatefulWidget {
  const CreatePaymentDialog({super.key});

  @override
  ConsumerState<CreatePaymentDialog> createState() =>
      _CreatePaymentDialogState();
}

class _CreatePaymentDialogState extends ConsumerState<CreatePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _currency = CurrencyFormatter.majorsList.first.code!.toUpperCase();
  DateTime? _dueDate;
  bool _isLoading = false;

  // Get all available currencies from currency_formatter
  late final List<CurrencyFormat> _currencies;

  final int _nameMaxLength = 50;
  final int _amountMaxDigits = 9;

  String? _dueDateError;
  String? _amountError;
  String? _nameError;

  String? _validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Please enter a payment name';
    }
    if (trimmed.length > _nameMaxLength) {
      return 'Name must be $_nameMaxLength characters or less';
    }
    return null;
  }

  String? _validateAmount(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Enter amount';
    }

    final amount = int.tryParse(trimmed);
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than zero';
    }

    return null;
  }

  bool _validateForm() {
    final nameError = _validateName(_nameController.text);
    final amountError = _validateAmount(_amountController.text);
    final dueDateError = _dueDate == null ? 'Please select a due date' : null;

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    setState(() {
      _nameError = nameError;
      _amountError = amountError;
      _dueDateError = dueDateError;
    });

    return nameError == null && amountError == null && dueDateError == null;
  }

  @override
  void initState() {
    super.initState();
    _currencies = CurrencyFormatter.majorsList;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateError = null;
      });
    }
  }

  Future<void> _createPayment() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = int.parse(_amountController.text.trim());

      await ref
          .read(paymentActionsProvider.notifier)
          .addPayment(
            name: _nameController.text.trim(),
            amount: amount,
            currency: _currency,
            dueDate: _dueDate,
          );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showError(
          context,
          "Failed to create payment.",
          extendedText: e.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create New Payment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Payment name field
                TextFormField(
                  controller: _nameController,
                  maxLength: _nameMaxLength,
                  onChanged: (_) {
                    if (_nameError == null) return;
                    setState(() {
                      _nameError = null;
                    });
                  },
                  decoration: getFormFieldDecoration(
                    labelText: 'Payment Name',
                    hintText: 'e.g. Entry fee',
                    themeData: Theme.of(context),
                    errorText: _nameError,
                    enabled: !_isLoading,
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Amount and currency fields
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount field
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        onChanged: (_) {
                          if (_amountError == null) return;
                          setState(() {
                            _amountError = null;
                          });
                        },
                        decoration: getFormFieldDecoration(
                          labelText: 'Amount',
                          hintText: '100',
                          themeData: Theme.of(context),
                          errorText: _amountError,
                          enabled: !_isLoading,
                        ),
                        maxLength: _amountMaxDigits,
                        enabled: !_isLoading,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Currency dropdown
                    IntrinsicWidth(
                      child: DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: getFormFieldDecoration(
                          labelText: 'Currency',
                          themeData: Theme.of(context),
                          enabled: !_isLoading,
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
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _currency = value;
                                  });
                                }
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Due date field
                InkWell(
                  onTap: _isLoading ? null : _selectDueDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: getFormFieldDecoration(
                      labelText: 'Due Date',
                      hintText: 'Select due date',
                      themeData: Theme.of(context),
                      enabled: !_isLoading,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: _dueDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _dueDate = null;
                                        _dueDateError = null;
                                      });
                                    },
                            )
                          : null,
                      errorText: _dueDateError,
                    ),
                    child: Text(
                      _dueDate != null
                          ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                          : 'No due date',
                      style: TextStyle(
                        color: _dueDateError != null
                            ? colorScheme.error
                            : _dueDate != null
                            ? _isLoading
                                  ? colorScheme.onSurface.withAlpha(128)
                                  : colorScheme.onSurface
                            : colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),

                    // Create button
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _createPayment,
                      icon: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: ThreeDotLoadingIndicator(
                                color: colorScheme.onSurface,
                                dotSize: 2,
                                orbitRadius: 5,
                                spinDuration: const Duration(milliseconds: 800),
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(_isLoading ? 'Creating...' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
