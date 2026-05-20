import 'package:flutter/material.dart';

class UnpaidOnlyFilterButton extends StatelessWidget {
  final bool showOnlyUnpaid;
  final ValueChanged<bool> onToggle;

  const UnpaidOnlyFilterButton({
    super.key,
    required this.showOnlyUnpaid,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Material(
            color: showOnlyUnpaid
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => onToggle(!showOnlyUnpaid),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      showOnlyUnpaid
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                      size: 18,
                      color: showOnlyUnpaid
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unpaid only',
                      style: TextStyle(
                        color: showOnlyUnpaid
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
