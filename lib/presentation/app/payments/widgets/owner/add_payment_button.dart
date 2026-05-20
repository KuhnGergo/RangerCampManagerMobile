import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/app/payments/payment_inforamtions.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/owner/create_payment_dialog.dart';

class AddPaymentButton extends StatelessWidget {
  const AddPaymentButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const CreatePaymentDialog(),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle, color: colorScheme.onPrimary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Add New Payment',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PaymentInforamtions(),
      ],
    );
  }
}
