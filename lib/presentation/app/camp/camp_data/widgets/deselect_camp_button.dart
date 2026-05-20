import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeselectCampButton extends ConsumerWidget {
  final VoidCallback deselectedCallback;

  const DeselectCampButton({super.key, required this.deselectedCallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      onPressed: () {
        deselectedCallback();
      },
      icon: Icon(Icons.arrow_back, size: 18),
      label: Text('Back to Camps'),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
