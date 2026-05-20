import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/owner/progress_capsule.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/owner/stats_card.dart';

class CollectionProgressHeader extends StatelessWidget {
  final int totalCollected;
  final int totalExpected;
  final String currency;

  const CollectionProgressHeader({
    super.key,
    required this.totalCollected,
    required this.totalExpected,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final remaining = totalExpected - totalCollected;
    final progress = totalExpected > 0 ? totalCollected / totalExpected : 1.0;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vertical progress capsule
            ProgressCapsule(
              progress: progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
              gradientColors: [
                colorScheme.primary,
                Color.alphaBlend(
                  colorScheme.primaryContainer.withAlpha(150),
                  colorScheme.primary,
                ),
              ],
              width: 50,
            ),
            const SizedBox(width: 12),

            // Stats cards
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Total collected card
                  StatsCard(
                    category: 'Total Collected',
                    currency: currency,
                    amount: totalCollected,

                    backgroundColor: colorScheme.tertiaryContainer,
                    textColor: colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(height: 12),
                  // Remaining card
                  StatsCard(
                    category: 'Total Remaining',
                    currency: currency,
                    amount: remaining,

                    backgroundColor: colorScheme.surfaceContainerHigh,
                    textColor: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
