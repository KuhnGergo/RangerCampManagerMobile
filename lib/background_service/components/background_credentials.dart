const kUserIdKey = 'bg_location_user_id';
const kCampIdKey = 'bg_location_camp_id';
const kTokenKey = 'bg_location_token';
const kServerUrlKey = 'bg_location_server_url';

// Watchdog: check every N minutes; restart if no position received in M minutes.
const kWatchdogCheckMinutes = 2;
const kWatchdogThresholdMinutes = 3;

/// Credentials cached in memory within the background isolate.
/// Loaded once from SharedPreferences at startup; updated on 'updateCredentials' events.
class Credentials {
  String userId;
  String campId;
  String token;
  String serverUrl;

  Credentials({
    required this.userId,
    required this.campId,
    required this.token,
    required this.serverUrl,
  });

  bool get canTrack =>
      userId.isNotEmpty &&
      campId.isNotEmpty &&
      token.isNotEmpty &&
      serverUrl.isNotEmpty;
}
