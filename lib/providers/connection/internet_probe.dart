import 'dart:io';

class InternetProbe {
  DateTime? _lastCheck;
  bool _lastResult = false;

  Future<bool> hasInternet() async {
    // throttle to avoid spamming DNS
    if (_lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < const Duration(seconds: 3)) {
      return _lastResult;
    }

    _lastCheck = DateTime.now();

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 1));
      _lastResult = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      _lastResult = false;
    }

    return _lastResult;
  }
}
