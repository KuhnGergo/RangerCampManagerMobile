import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:intl/intl.dart';
import 'package:mastercs_mobile/utils/payment_formatter_utils.dart';

class PaymentInfoCard extends StatelessWidget {
  final Payment payment;

  const PaymentInfoCard({super.key, required this.payment});

  String _formatDate(DateTime? date) {
    if (date == null) return 'No due date';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withAlpha(180),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PaymentFormatterUtils.formatAmount(
                      payment.amount,
                      payment.currency,
                    ),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Due Date',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withAlpha(180),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(payment.dueDate),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
