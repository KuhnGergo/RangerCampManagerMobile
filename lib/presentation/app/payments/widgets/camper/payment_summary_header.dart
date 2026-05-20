import 'package:flutter/material.dart';
import 'package:mastercs_mobile/utils/payment_formatter_utils.dart';

class PaymentSummaryHeader extends StatelessWidget {
  final int upcomingAmount;
  final int paidAmount;
  final String currency;

  const PaymentSummaryHeader({
    super.key,
    required this.upcomingAmount,
    required this.paidAmount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Upcoming payments card
          Expanded(
            child: _SummaryCard(
              category: 'Upcoming',
              currency: currency,
              amount: upcomingAmount,
              icon: Icons.schedule,
              backgroundColor: colorScheme.surfaceContainerHigh,
              textColor: colorScheme.onSurfaceVariant,
              iconColor: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          // Paid card
          Expanded(
            child: _SummaryCard(
              category: 'Paid',
              currency: currency,
              amount: paidAmount,
              icon: Icons.check_circle,
              backgroundColor: colorScheme.tertiaryContainer,
              textColor: colorScheme.onTertiaryContainer,
              iconColor: colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String category;
  final String currency;
  final int amount;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const _SummaryCard({
    required this.category,
    required this.currency,
    required this.amount,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: textColor.withAlpha(180),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            PaymentFormatterUtils.formatAmount(amount, currency),
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
