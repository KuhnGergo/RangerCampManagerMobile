import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/widgets/profile_section_card.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/permission_information_dialog.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/permission_status_tile.dart';
import 'package:mastercs_mobile/presentation/settings/widgets/section_action_tile.dart';
import 'package:mastercs_mobile/providers/location/location_permission_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionsSection extends ConsumerStatefulWidget {
  const LocationPermissionsSection({super.key});

  @override
  ConsumerState<LocationPermissionsSection> createState() =>
      _LocationPermissionsSectionState();
}

class _LocationPermissionsSectionState
    extends ConsumerState<LocationPermissionsSection>
    with WidgetsBindingObserver {
  LocationPermissionState state = const LocationPermissionState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh permission status when returning from app settings
    if (state == AppLifecycleState.resumed) {
      ref.read(locationPermissionProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final permState = ref.watch(locationPermissionProvider);

    permState.maybeWhen(orElse: () {}, data: (newState) => state = newState);

    return ProfileSectionCard(
      title: 'Background Location',
      children: [
        Column(
          children: [
            SectionActionTile(
              icon: Icons.info_outline,
              label: 'Why do we need this?',
              onTap: () => showPermissionInformationDialog(context),
            ),
            const SizedBox(height: 8),
            PermissionStatusTile(
              icon: Icons.location_on_outlined,
              label: 'Background Location',
              subtitle: state.isAlwaysGranted
                  ? 'Always allowed'
                  : 'Not allowed',
              isGranted: state.isAlwaysGranted,
              onTap: state.isAlwaysGranted
                  ? openAppSettings
                  : () => ref
                        .read(locationPermissionProvider.notifier)
                        .requestAlways(),
            ),
            if (Platform.isAndroid) ...[
              const SizedBox(height: 8),
              PermissionStatusTile(
                icon: Icons.battery_saver_outlined,
                label: 'Battery Optimization',
                subtitle: state.isBatteryOptimizationIgnored
                    ? 'Unrestricted - optimization enabled'
                    : 'Restricted - background tracking still works',
                isGranted: state.isBatteryOptimizationIgnored,
                onTap: state.isBatteryOptimizationIgnored
                    ? openAppSettings
                    : () => ref
                          .read(locationPermissionProvider.notifier)
                          .requestBatteryOptimization(),
              ),
              const SizedBox(height: 8),
              PermissionStatusTile(
                icon: Icons.directions_walk_outlined,
                label: 'Activity Recognition',
                subtitle: state.isActivityRecognitionGranted
                    ? 'Granted - optimization enabled'
                    : 'Not granted - background tracking still works',
                isGranted: state.isActivityRecognitionGranted,
                onTap: state.isActivityRecognitionGranted
                    ? openAppSettings
                    : () => ref
                          .read(locationPermissionProvider.notifier)
                          .requestActivityRecognition(),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
