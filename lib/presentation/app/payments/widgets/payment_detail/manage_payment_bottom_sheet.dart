import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/presentation/app/payments/dialogs/change_payment_currency_dialog.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/text_update_dialog.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/warning_dialog.dart';
import 'package:mastercs_mobile/presentation/components/widgets/option_action.dart';
import 'package:mastercs_mobile/providers/actions/payment_actions_provider.dart';

Future<bool?> showManagePaymentBottomSheet(
  BuildContext context,
  WidgetRef ref, {
  required Payment payment,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ManagePaymentBottomSheet(
      actionRef: ref,
      sourceContext: context,
      payment: payment,
    ),
  );
}

class ManagePaymentBottomSheet extends ConsumerWidget {
  final WidgetRef actionRef;
  final BuildContext sourceContext;
  final Payment payment;

  const ManagePaymentBottomSheet({
    super.key,
    required this.actionRef,
    required this.sourceContext,
    required this.payment,
  });

  void _changePaymentName(BuildContext context) {
    Navigator.pop(context);
    showTextUpdateDialog(
      context: sourceContext,
      errorContext: sourceContext,
      title: 'Change Payment Name',
      label: 'Payment Name',
      initialValue: payment.name,
      hintText: 'Enter payment name',
      genericErrorMessage: 'Failed to update payment name',
      maxLength: 100,
      validator: (value) {
        if (value.isEmpty) return 'Payment name cannot be empty';
        if (value.length < 3) {
          return 'Payment name must be at least 3 characters';
        }
        return null;
      },
      confirmAction: (newName) => actionRef
          .read(paymentActionsProvider.notifier)
          .updatePayment(paymentId: payment.remoteId, name: newName),
    );
  }

  void _changePaymentAmount(BuildContext context) {
    Navigator.pop(context);
    showTextUpdateDialog(
      context: sourceContext,
      errorContext: sourceContext,
      title: 'Change Payment Amount',
      label: 'Amount',
      initialValue: payment.amount.toString(),
      hintText: 'Enter amount (e.g. 49)',
      genericErrorMessage: 'Failed to update payment amount',
      informationText:
          'Amount is meant to be a whole number in major currency units (e.g. dollars, euros) and will be converted to cents internally.',
      maxLength: 12,

      validator: (value) {
        if (value.isEmpty) return 'Amount cannot be empty';
        final parsed = int.tryParse(value);
        if (parsed == null) return 'Amount must be a whole number';
        if (parsed <= 0) return 'Amount must be greater than 0';
        return null;
      },
      confirmAction: (newAmount) {
        final amount = int.parse(newAmount);
        return actionRef
            .read(paymentActionsProvider.notifier)
            .updatePayment(paymentId: payment.remoteId, amount: amount);
      },
    );
  }

  void _changePaymentCurrency(BuildContext context) {
    Navigator.pop(context);
    showChangePaymentCurrencyDialog(
      context: sourceContext,
      errorContext: sourceContext,
      title: 'Change Payment Currency',
      initialCurrency: payment.currency,
      genericErrorMessage: 'Failed to update payment currency',
      confirmAction: (newCurrency) => actionRef
          .read(paymentActionsProvider.notifier)
          .updatePayment(paymentId: payment.remoteId, currency: newCurrency),
    );
  }

  void _deletePayment(BuildContext context) {
    showWarningDialog(
      context: context,
      title: 'Delete Payment',
      secondThoughtLabel: 'Are you sure you want to delete this payment?',
      message:
          'This action cannot be undone and related user payment records will be removed.',
      confirmLabel: 'Delete',
      confirmAction: () async {
        await actionRef
            .read(paymentActionsProvider.notifier)
            .removePayment(paymentId: payment.remoteId);
      },
      onConfirmed: () {
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      },
      genericErrorMessage: 'Failed to delete payment',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(102),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payments, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Manage Payment',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            OptionAction(
              onPressed: () => _changePaymentName(context),
              icon: Icons.edit,
              label: 'Change Payment Name',
            ),
            OptionAction(
              onPressed: () => _changePaymentAmount(context),
              icon: Icons.attach_money,
              label: 'Change Payment Amount',
            ),
            OptionAction(
              onPressed: () => _changePaymentCurrency(context),
              icon: Icons.currency_exchange,
              label: 'Change Payment Currency',
            ),
            OptionAction(
              onPressed: () => _deletePayment(context),
              icon: Icons.delete_forever,
              color: colorScheme.error,
              label: 'Delete Payment',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
