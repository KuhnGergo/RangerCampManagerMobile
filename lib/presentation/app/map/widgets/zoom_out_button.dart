import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/map/map_controller.dart';

class ZoomOutButton extends ConsumerWidget {
  const ZoomOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = ref.read(mapControllerProvider.notifier);

    return Container(
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
          onTap: controller.zoomOut,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(Icons.remove, color: colorScheme.onSurface, size: 20),
          ),
        ),
      ),
    );
  }
}
