// ---------------------------------------------------------------------------
// BackgroundLocationManager — main-isolate API
// ---------------------------------------------------------------------------

import 'dart:developer' as dev;

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mastercs_mobile/background_service/components/background_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the background location service from the main isolate.
class BackgroundLocationManager {
  static final _service = FlutterBackgroundService();
  static Future<void>? _startOp;
  static Future<void>? _stopOp;
  static bool _isStarting = false;
  static bool _isStopping = false;

  static Future<void> start({
    required String userId,
    required String campId,
    required String token,
    required String serverUrl,
  }) async {
    if (_startOp != null) {
      await _startOp;
      return;
    }

    _startOp = _startInternal(
      userId: userId,
      campId: campId,
      token: token,
      serverUrl: serverUrl,
    );
    try {
      await _startOp;
    } finally {
      _startOp = null;
    }
  }

  static Future<void> _startInternal({
    required String userId,
    required String campId,
    required String token,
    required String serverUrl,
  }) async {
    if (userId.isEmpty ||
        token.isEmpty ||
        serverUrl.isEmpty ||
        campId.isEmpty) {
      dev.log(
        'start skipped - missing required credentials or campId',
        name: 'BgLocationService',
      );
      return;
    }

    if (_isStopping && _stopOp != null) {
      await _stopOp;
    }

    _isStarting = true;
    try {
      // Persist all credentials before starting so the isolate can read them.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kUserIdKey, userId);
      await prefs.setString(kCampIdKey, campId);
      await prefs.setString(kTokenKey, token);
      await prefs.setString(kServerUrlKey, serverUrl);

      final isRunning = await _service.isRunning();
      if (!isRunning) {
        await _service.startService();
      }
      // Push fresh credentials in case the service was already running.
      _service.invoke('updateCredentials', {
        'userId': userId,
        'campId': campId,
        'token': token,
        'serverUrl': serverUrl,
      });
    } finally {
      _isStarting = false;
    }
  }

  static Future<void> stop() async {
    if (_stopOp != null) {
      await _stopOp;
      return;
    }

    _stopOp = _stopInternal();
    try {
      await _stopOp;
    } finally {
      _stopOp = null;
    }
  }

  static Future<void> _stopInternal() async {
    _isStopping = true;
    try {
      if (_isStarting && _startOp != null) {
        await _startOp;
      }

      if (await _service.isRunning()) {
        _service.invoke('stopService');
      }
    } finally {
      _isStopping = false;
    }
  }

  static Future<bool> isRunning() => _service.isRunning();

  /// Update individual credentials without restarting the service.
  static void updateCredentials({
    String? userId,
    String? campId,
    String? token,
    String? serverUrl,
  }) {
    _service.invoke('updateCredentials', {
      if (userId != null) 'userId': userId,
      if (campId != null) 'campId': campId,
      if (token != null) 'token': token,
      if (serverUrl != null) 'serverUrl': serverUrl,
    });
  }

  /// Switch GPS accuracy profile. Call when app goes foreground / background.
  static void setProfile({required bool isForeground}) {
    _service.invoke('setProfile', {'isForeground': isForeground});
  }
}
