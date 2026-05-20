import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentDateSeparator extends StatelessWidget {
  final DateTime? date;

  const PaymentDateSeparator({super.key, required this.date});

  String _formatDate(DateTime? date) {
    if (date == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) {
      return 'Today - ${DateFormat('MMM dd, yyyy').format(date)}';
    } else if (difference == 1) {
      return 'Tomorrow - ${DateFormat('MMM dd, yyyy').format(date)}';
    } else if (difference == -1) {
      return 'Yesterday - ${DateFormat('MMM dd, yyyy').format(date)}';
    } else if (difference > 1 && difference <= 7) {
      return '${DateFormat('EEEE').format(date)} - ${DateFormat('MMM dd, yyyy').format(date)}';
    } else {
      return DateFormat('EEEE, MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4, right: 4),
      child: Row(
        children: [
          Text(
            _formatDate(date),
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: colorScheme.outline.withAlpha(50),
            ),
          ),
        ],
      ),
    );
  }
}
