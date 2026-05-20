import 'package:flutter/material.dart';
import 'package:mastercs_mobile/utils/payment_formatter_utils.dart';

class StatsCard extends StatelessWidget {
  final String category;
  final String currency;
  final int amount;
  final Color backgroundColor;
  final Color textColor;

  const StatsCard({
    super.key,
    required this.category,
    required this.currency,
    required this.amount,
    required this.backgroundColor,
    required this.textColor,
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
                style: TextStyle(color: textColor.withAlpha(150), fontSize: 14),
              ),
            ],
          ),
          Text(
            PaymentFormatterUtils.formatAmount(amount, currency),
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
