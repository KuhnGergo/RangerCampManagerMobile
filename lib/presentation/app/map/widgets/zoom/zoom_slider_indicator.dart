import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/map/map_controller.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/zoom/custom_slider_thumb_shape.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/zoom/custom_slider_track.dart';
import 'package:mastercs_mobile/providers/location/layer_provider.dart';

class ZoomSliderIndicator extends ConsumerStatefulWidget {
  const ZoomSliderIndicator({super.key});

  @override
  ConsumerState<ZoomSliderIndicator> createState() =>
      _ZoomSliderIndicatorState();
}

class _ZoomSliderIndicatorState extends ConsumerState<ZoomSliderIndicator> {
  static const double minZoom = 6.0;
  static const double thumbHeight = 60.0;
  static const double thumbWidth = 7.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = ref.read(mapControllerProvider.notifier);
    final state = ref.watch(mapControllerProvider);
    final currentLayer = ref.watch(layerProvider);
    final maxZoom = currentLayer.maxZoom;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 4,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surfaceContainerHighest,
              boxShadow: [BoxShadow(color: colorScheme.shadow, blurRadius: 18)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28.0),
          child: RotatedBox(
            quarterTurns:
                1, // Rotate 90 degrees to make vertical (bottom to top)
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                trackShape: CustomTrackShape(
                  activeColor: colorScheme.surfaceContainerHighest,
                  inactiveColor: colorScheme.surfaceContainerHighest,
                ),
                activeTrackColor: colorScheme.surfaceContainerHighest,
                inactiveTrackColor: colorScheme.surfaceContainerHighest,
                activeTickMarkColor: colorScheme.surfaceContainerHighest,
                inactiveTickMarkColor: colorScheme.surfaceContainerHighest,
                thumbShape: CustomThumbShape(
                  thumbHeight: thumbHeight,
                  thumbWidth: thumbWidth,
                  color: colorScheme.onSurfaceVariant,
                  shadowColor: colorScheme.shadow,
                ),
                overlayShape: SliderComponentShape.noOverlay,
                showValueIndicator: ShowValueIndicator.never,
              ),
              child: Slider(
                value: state.zoom,
                min: minZoom,
                max: maxZoom,
                divisions: ((maxZoom - minZoom).abs() * 10).round(),
                label: state.zoom.toStringAsFixed(1),
                onChanged: (value) {
                  controller.setZoom(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
