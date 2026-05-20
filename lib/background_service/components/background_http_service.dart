import 'dart:convert';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

/// Lightweight HTTP client used exclusively inside the background service
/// isolate. Riverpod is not available there, so credentials are passed
/// directly rather than read from providers.
class BackgroundHttpService {
  String _baseUrl;
  String _token;
  final http.Client _client;

  BackgroundHttpService({String baseUrl = '', String token = ''})
    : _baseUrl = baseUrl,
      _token = token,
      _client = http.Client();

  /// Update credentials after the isolate receives an 'updateCredentials' event.
  void updateCredentials({String? baseUrl, String? token}) {
    if (baseUrl != null) _baseUrl = baseUrl;
    if (token != null) _token = token;
  }

  /// POST /camps/{campId}/location
  /// Returns true if the server acknowledged the update (2xx response).
  Future<bool> sendLocation({
    required String campId,
    required double latitude,
    required double longitude,
  }) async {
    if (_baseUrl.isEmpty || _token.isEmpty || campId.isEmpty) {
      dev.log(
        'sendLocation skipped — missing baseUrl/token/campId',
        name: 'BgHttpService',
      );
      return false;
    }

    final url = Uri.parse('$_baseUrl/camps/$campId/location');

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $_token',
            },
            body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
          )
          .timeout(const Duration(seconds: 10));

      final ok = response.statusCode >= 200 && response.statusCode < 300;
      if (!ok) {
        dev.log(
          'sendLocation failed: ${response.statusCode} ${response.body}',
          name: 'BgHttpService',
        );
      }
      return ok;
    } catch (e) {
      dev.log('sendLocation error: $e', name: 'BgHttpService');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
