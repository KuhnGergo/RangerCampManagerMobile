import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mastercs_mobile/utils/camp_status_helper.dart';

class DateRange extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({super.key, required this.startDate, required this.endDate});

  String get startFormatted => DateFormat('MMM dd').format(startDate);
  String get endFormatted => DateFormat('MMM dd, yyyy').format(endDate);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final statusInfo = CampStatusHelper.getCampStatus(
      startDate: startDate,
      endDate: endDate,
      colorScheme: Theme.of(context).colorScheme,
    );

    final statusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusInfo.color.withAlpha(51),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusInfo.distanceText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: statusInfo.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.event, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$startFormatted – $endFormatted',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          statusBadge,
        ],
      ),
    );
  }
}
