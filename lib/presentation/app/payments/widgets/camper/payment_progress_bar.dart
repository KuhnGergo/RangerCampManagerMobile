import 'package:flutter/material.dart';
import 'package:mastercs_mobile/utils/progress_color_utils.dart';

class PaymentProgressBar extends StatelessWidget {
  final int paidAmount;
  final int totalAmount;
  final String currency;

  const PaymentProgressBar({
    super.key,
    required this.paidAmount,
    required this.totalAmount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = totalAmount > 0 ? paidAmount / totalAmount : 0.0;
    final percentage = (progress * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Progress',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentage% Complete',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                ProgressColorUtils.toColor(progress),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
