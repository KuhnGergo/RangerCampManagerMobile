import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/presentation/app/payments/provider/payment_detail_data_provider.dart';
import 'package:mastercs_mobile/providers/actions/payment_actions_provider.dart';
import 'package:mastercs_mobile/utils/payment_formatter_utils.dart';
import 'package:mastercs_mobile/utils/progress_color_utils.dart';
import 'package:mastercs_mobile/utils/time_utils.dart';

/// A single payment row with paid/unpaid toggle for a specific user.
class PaymentItemTile extends ConsumerWidget {
  final Payment payment;
  final String userId;

  const PaymentItemTile({
    super.key,
    required this.payment,
    required this.userId,
  });

  Color _dueColor(bool isPaid, DateTime? dueDate, ColorScheme colorScheme) {
    if (isPaid) return Colors.green;
    if (dueDate == null) return colorScheme.onSurfaceVariant;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final days = due.difference(today).inDays;
    if (days < 0) return colorScheme.error;
    if (days <= 3) return Colors.orange;
    return colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPaid = ref
        .watch(paymentDetailDataProvider)
        .isMemberPaid(userId, payment.remoteId);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          try {
            await ref
                .read(paymentActionsProvider.notifier)
                .setUserPayment(
                  paymentId: payment.remoteId,
                  userId: userId,
                  isPaid: !isPaid,
                );
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Row(
            children: [
              // Due date badge
              Container(
                width: 60,
                height: 32,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _dueColor(
                    isPaid,
                    payment.dueDate,
                    colorScheme,
                  ).withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatTimeUntilDue(payment.dueDate),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _dueColor(isPaid, payment.dueDate, colorScheme),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Payment name and amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      PaymentFormatterUtils.formatAmount(
                        payment.amount,
                        payment.currency,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPaid
                      ? ProgressColorUtils.toColor(1.0)
                      : colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: isPaid
                        ? ProgressColorUtils.toColor(1.0)
                        : colorScheme.outline.withAlpha(80),
                    width: 2,
                  ),
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isPaid ? 1.0 : 0.0,
                  child: Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
