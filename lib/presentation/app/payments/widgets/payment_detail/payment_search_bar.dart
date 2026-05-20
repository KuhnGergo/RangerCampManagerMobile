import 'package:flutter/material.dart';

class PaymentSearchBar extends StatelessWidget {
  final String searchQuery;
  final Function(String) onChanged;
  final VoidCallback onReset;

  const PaymentSearchBar({
    super.key,
    required this.searchQuery,
    required this.onChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search members...',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withAlpha(150),
            ),
            prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onReset,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
