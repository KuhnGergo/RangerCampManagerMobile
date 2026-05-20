import 'package:flutter/material.dart';

class MinGroupSizeCard extends StatelessWidget {
  final int? minGroupSize;

  const MinGroupSizeCard({super.key, required this.minGroupSize});

  @override
  Widget build(BuildContext context) {
    if (minGroupSize == null) {
      return SizedBox.shrink();
    }

    return Row(
      children: [
        Text(
          'Minimum Group Size:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$minGroupSize',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
