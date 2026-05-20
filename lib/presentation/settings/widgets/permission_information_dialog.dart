import 'package:flutter/material.dart';

void showPermissionInformationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const PermissionInformationDialog(),
  );
}

class PermissionInformationDialog extends StatelessWidget {
  const PermissionInformationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          const Text(
            'Why do we need this?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(
            textAlign: TextAlign.start,
            'We need constant location access to provide the core functionality of the app. Without it location sharing fails at the background.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            textAlign: TextAlign.start,
            'Granting Battery Optimization ensures that your location is updated reliably even when the phone tries to save battery by limiting our features.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            textAlign: TextAlign.start,
            'Granting Activity Recognition will reduce battery consumption by allowing us to pause location updates when you are still.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
