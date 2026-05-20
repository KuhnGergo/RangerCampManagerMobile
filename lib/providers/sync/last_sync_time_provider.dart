import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/shared_preferences_provider.dart';

const String _lastSyncTimeKey = 'last_sync_time_ms';

/// Provides the last sync time in milliseconds since epoch.
/// Returns null if never synced before.
final lastSyncTimeProvider = Provider<int?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getInt(_lastSyncTimeKey);
});

/// Notifier for managing sync time updates
final lastSyncTimeNotifierProvider =
    NotifierProvider<LastSyncTimeNotifier, void>(LastSyncTimeNotifier.new);

class LastSyncTimeNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Updates the last sync time to the current time
  Future<void> updateLastSyncTime() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_lastSyncTimeKey, DateTime.now().millisecondsSinceEpoch);
    // Invalidate the provider to refresh the value
    ref.invalidate(lastSyncTimeProvider);
  }
}

/// Checks if enough time has passed since the last sync (default: 5 minutes)
/// Returns true if:
/// - Never synced before (lastSyncTime is null)
/// - 5 minutes or more have passed since last sync
final canSyncByTimeProvider = Provider<bool>((ref) {
  final lastSyncTime = ref.watch(lastSyncTimeProvider);

  // If never synced, allow sync
  if (lastSyncTime == null) {
    return true;
  }

  final now = DateTime.now().millisecondsSinceEpoch;
  final timeSinceLastSync = now - lastSyncTime;

  // 5 minutes in milliseconds
  const fiveMinutesInMs = 5 * 60 * 1000;

  return timeSinceLastSync >= fiveMinutesInMs;
});
