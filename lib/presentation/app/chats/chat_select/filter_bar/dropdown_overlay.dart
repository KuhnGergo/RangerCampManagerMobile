import 'package:flutter/material.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/filter_bar/reorderable_dropdown_list.dart';

class DropdownOverlay extends StatelessWidget {
  final LayerLink layerLink;
  final VoidCallback onDismiss;

  const DropdownOverlay({
    super.key,
    required this.layerLink,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        /// Tap outside → dismiss
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),

        /// Anchored dropdown
        CompositedTransformFollower(
          link: layerLink,
          offset: const Offset(0, 40), // below button
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.drag_indicator,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Drag to reorder priority',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant),
                  const ReorderableDropdownList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
