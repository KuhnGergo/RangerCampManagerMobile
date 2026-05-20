import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/location/location_permission_provider.dart';

/// A compact widget that displays location permission warning.
/// Shows nothing when all background tracking permissions are granted.
/// Shows a tappable warning when background permissions are missing.
///
/// Indicators only disappear when canTrackBackground is true, meaning:
/// - Location service is enabled
/// - Location permission is set to "always"
///
/// Activity recognition and battery optimization are optional optimizations.
class LocationPermissionIndicator extends ConsumerWidget {
  const LocationPermissionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final permissionState = ref.watch(locationPermissionProvider);

    // Only hide when all background permissions are satisfied
    if (permissionState.value == null ||
        permissionState.value!.canTrackBackground) {
      return const SizedBox.shrink();
    }

    final state = permissionState.value!;
    final canTrackForeground = state.canTrackForeground;

    return GestureDetector(
      onTap: () async {
        // Request all required background permissions in sequence
        await ref
            .read(locationPermissionProvider.notifier)
            .requestAllBackgroundPermissions();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: canTrackForeground
              ? Colors.orange.shade900
              : colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              canTrackForeground ? Icons.location_on : Icons.location_off,
              size: 14,
              color: colorScheme.onError,
            ),
            const SizedBox(width: 6),
            Text(
              canTrackForeground
                  ? 'Enable background tracking'
                  : 'Enable location permission',
              style: TextStyle(
                color: colorScheme.onError,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios, size: 10, color: colorScheme.onError),
          ],
        ),
      ),
    );
  }
}
