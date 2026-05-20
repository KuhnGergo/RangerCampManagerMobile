import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/utils/payment_formatter_utils.dart';

class CamperPaymentListItem extends StatelessWidget {
  final Payment payment;
  final bool isPaid;
  final bool showCurrency;

  const CamperPaymentListItem({
    super.key,
    required this.payment,
    required this.isPaid,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withAlpha(50),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Currency symbol indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPaid
                    ? colorScheme.tertiaryContainer
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  showCurrency
                      ? PaymentFormatterUtils.getCurrencySymbol(
                          payment.currency,
                        )
                      : (isPaid ? '✓' : '⏱'),
                  style: TextStyle(
                    color: isPaid
                        ? colorScheme.tertiary
                        : colorScheme.onSurfaceVariant,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Payment info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? colorScheme.tertiaryContainer
                          : colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPaid ? 'PAID' : 'PENDING',
                      style: TextStyle(
                        color: isPaid
                            ? colorScheme.tertiary
                            : colorScheme.onErrorContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              PaymentFormatterUtils.formatAmount(
                payment.amount,
                payment.currency,
              ),
              style: TextStyle(
                color: isPaid ? colorScheme.tertiary : colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
