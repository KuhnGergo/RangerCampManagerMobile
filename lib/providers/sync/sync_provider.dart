import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/connection/connectivity_provider.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';
import 'package:mastercs_mobile/providers/sync/sync_policy.dart';
import 'package:mastercs_mobile/providers/sync/last_sync_time_provider.dart';

/// Provides whether syncing is allowed based on current connectivity, sync policy, and time-based cooldown.
/// Only allows sync if:
/// - Connected to internet (not offline)
/// - Connection type matches sync policy (mobile/wifi)
/// - At least 5 minutes have passed since last sync
///
/// ### Used as API call guard:
/// ```dart
/// void SomeSubmit() async {
///   if (!ref.read(canSyncProvider)) {
///    queueRequestOffline();
///    return;
///  }
///
///  await api.fetchData();
///}
/// ```
/// Possible values are: `true`, `false`
final canSyncProvider = Provider<bool>((ref) {
  final connection = ref.watch(connectivityProvider).value;
  final policy = ref.watch(syncPolicyProvider);
  final canSyncByTime = ref.watch(canSyncByTimeProvider);
  final auth = ref.watch(authProvider.notifier);

  if (!auth.isLoggedIn) {
    return false;
  }

  // Check time-based cooldown first
  if (!canSyncByTime) {
    return false;
  }

  if (connection == null || connection == InternetStatus.offline) {
    return false;
  }

  switch (connection) {
    case InternetStatus.mobile:
      return policy.allowMobile;
    case InternetStatus.wifi:
    case InternetStatus.ethernet:
      return policy.allowWifi;
    case InternetStatus.offline:
      return false;
  }
});
