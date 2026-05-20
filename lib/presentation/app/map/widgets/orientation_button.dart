import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/map/map_controller.dart';
import 'dart:math' as math;

class OrientationButton extends ConsumerWidget {
  const OrientationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = ref.read(mapControllerProvider.notifier);
    final state = ref.watch(mapControllerProvider);

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
          onTap: controller.resetRotation,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: state.rotation * math.pi / 180,
              child: Icon(
                Icons.navigation,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
