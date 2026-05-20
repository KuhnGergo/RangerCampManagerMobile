import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/location/layer_provider.dart';

class LayerSwitcher extends ConsumerStatefulWidget {
  const LayerSwitcher({super.key});

  @override
  ConsumerState<LayerSwitcher> createState() => _LayerSwitcherState();
}

class _LayerSwitcherState extends ConsumerState<LayerSwitcher> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  IconData _getIconForLayer(MapLayer layer) {
    switch (layer) {
      case MapLayer.basic:
        return Icons.map;
      case MapLayer.outdoor:
        return Icons.terrain;
      case MapLayer.winter:
        return Icons.ac_unit;
      case MapLayer.aerial:
        return Icons.satellite_alt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLayer = ref.watch(layerProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Layer options (shown when expanded)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _isExpanded
              ? Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: MapLayer.values.map((layer) {
                      final isSelected = layer == currentLayer;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(layerProvider.notifier)
                                  .selectLayer(layer);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.surfaceContainerHighest,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getIconForLayer(layer),
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    layer.displayName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurface,
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // Main button (layers icon or close icon)
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            shape: BoxShape.circle,
          ),
          child: Material(
            color: colorScheme.surface,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _toggleExpanded,
              customBorder: const CircleBorder(),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  _isExpanded ? Icons.close : Icons.layers,
                  color: colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
