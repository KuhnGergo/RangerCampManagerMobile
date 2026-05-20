import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_circle.dart';
import 'package:mastercs_mobile/providers/data/account_provider.dart';
import 'package:mastercs_mobile/providers/location/location_permission_provider.dart';

/// A reusable account avatar widget that displays the current user's avatar.
/// Typically placed in app bars or profile sections.
/// Tapping navigates to the settings screen.
/// Shows an error indicator if background location permission is not set to "always".
class AccountAvatar extends ConsumerWidget {
  final String? displayText;

  const AccountAvatar({super.key, this.displayText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider);
    final permState = ref.watch(locationPermissionProvider);
    // Show error indicator if background tracking permissions are not fully granted
    final showError =
        permState.whenOrNull(data: (state) => !state.canTrackBackground) ??
        false;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/settings');
      },
      child: account.when(
        data: (data) {
          final filename = data?.profilePicturePath;
          return AccountCircle(
            name: displayText ?? data?.name ?? '?',
            userId: data?.remoteId,
            fileName: filename,
            radius: 20,
            showOnlineIndicator: false,
            showErrorIndicator: showError,
          );
        },
        loading: () => const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (error, stack) => AccountCircle(
          radius: 20,
          name: displayText ?? '?',
          userId: null,
          fileName: null,
          showOnlineIndicator: false,
          showErrorIndicator: showError,
        ),
      ),
    );
  }
}
