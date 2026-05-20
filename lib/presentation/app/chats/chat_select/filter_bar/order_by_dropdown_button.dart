import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/filter_bar/dropdown_overlay.dart';

/// A dropdown button that displays and allows reordering of sort criteria
class OrderByDropdownButton extends ConsumerStatefulWidget {
  const OrderByDropdownButton({super.key});

  @override
  ConsumerState<OrderByDropdownButton> createState() =>
      _OrderByDropdownButtonState();
}

class _OrderByDropdownButtonState extends ConsumerState<OrderByDropdownButton> {
  bool _isExpanded = false;

  final LayerLink layerLink = LayerLink();
  OverlayEntry? overlayEntry;

  void removeDropdown() {
    overlayEntry?.remove();
    overlayEntry = null;
    setState(() {
      _isExpanded = false;
    });
  }

  OverlayEntry createOverlay() {
    return OverlayEntry(
      builder: (context) =>
          DropdownOverlay(layerLink: layerLink, onDismiss: removeDropdown),
    );
  }

  void toggleDropdown() {
    if (overlayEntry != null) {
      removeDropdown();
      return;
    }
    overlayEntry = createOverlay();
    setState(() {
      _isExpanded = true;
    });
    Overlay.of(context).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CompositedTransformTarget(
      link: layerLink,
      child: Material(
        color: _isExpanded
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: toggleDropdown,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_vert, size: 18, color: colorScheme.onSurface),
                const SizedBox(width: 6),
                Text(
                  'Sort',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
