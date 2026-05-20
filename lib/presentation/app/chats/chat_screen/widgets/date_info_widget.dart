import 'package:flutter/material.dart';
import 'package:mastercs_mobile/utils/time_utils.dart';

class DateInfoWidget extends StatelessWidget {
  final DateTime timestamp;
  const DateInfoWidget({super.key, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 4),
          child: Text(
            formatDateTimeForDisplay(timestamp),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
