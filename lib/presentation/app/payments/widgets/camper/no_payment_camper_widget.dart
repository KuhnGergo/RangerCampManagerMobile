import 'package:flutter/material.dart';

class NoPaymentCamperWidget extends StatelessWidget {
  const NoPaymentCamperWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment,
              size: 64,
              color: colorScheme.onSurface.withAlpha(150),
            ),
            SizedBox(height: 16),
            Text(
              'There are no payments yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurface.withAlpha(150),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You have nothing to worry about.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              'For now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
