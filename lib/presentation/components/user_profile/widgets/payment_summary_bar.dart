import 'package:flutter/material.dart';
import 'package:mastercs_mobile/utils/progress_color_utils.dart';

/// A brief summary bar showing paid / total counts and a progress indicator.
class PaymentSummaryBar extends StatelessWidget {
  final int paidCount;
  final int totalCount;

  const PaymentSummaryBar({
    super.key,
    required this.paidCount,
    required this.totalCount,
  });

  double get _progress => totalCount > 0 ? paidCount / totalCount : 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$paidCount / $totalCount paid',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: ProgressColorUtils.toColor(_progress),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              ProgressColorUtils.toColor(_progress),
            ),
          ),
        ),
      ],
    );
  }
}
