import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mastercs_mobile/data/api/requests/auth_api.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = ref.watch(authApiProvider);
  return AuthRepository(authApi);
});

class AuthRepository {
  final AuthApi _api;
  final safeStorage = FlutterSecureStorage();

  AuthRepository(this._api);

  String _getTokenFromResponse(Map<String, dynamic> response) {
    if (response['data']['token'] != null) {
      return response['data']['token'] as String;
    }
    throw ('Token not found in response');
  }

  String _getUserIdFromResponse(Map<String, dynamic> response) {
    if (response['data']['userId'] != null) {
      return response['data']['userId'] as String;
    }
    throw ('User ID not found in response');
  }

  Future<Map<String, String>> login(String email, String password) async {
    try {
      // Call the API to login
      final response = await _api.login(email: email, password: password);

      // Extract response
      final token = _getTokenFromResponse(response);
      final userId = _getUserIdFromResponse(response);

      // Save token securely
      return await localLogin(token, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> register({
    required String email,
    required String password,
    required String username,
    String? profilePicturePath,
    String? phoneNumber,
    String? emergencyContact,
  }) async {
    try {
      // Call the API to register
      final response = await _api.register(
        email: email,
        password: password,
        username: username,
        profilePicturePath: profilePicturePath,
        phoneNumber: phoneNumber,
        emergencyContact: emergencyContact,
      );

      // Extract response
      final token = _getTokenFromResponse(response);
      final userId = _getUserIdFromResponse(response);

      // Save token securely
      return await localLogin(token, userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> localLogin(String token, String userId) async {
    // Save token and userId securely
    await safeStorage.write(key: 'token', value: token);
    await safeStorage.write(key: 'userId', value: userId);
    return {'token': token, 'userId': userId};
  }

  Future<Map<String, String>?> tryAutoLogin() async {
    final token = await safeStorage.read(key: 'token');
    final userId = await safeStorage.read(key: 'userId');
    if (token != null && userId != null) {
      return {'token': token, 'userId': userId};
    }
    return null;
  }

  Future<bool> hasUser(String email) async {
    return await _api.hasUser(email);
  }

  Future<void> forgotPassword(String email) async {
    await _api.forgotPassword(email);
  }

  Future<void> logout({bool fireApi = true}) async {
    // IMPORTANT: after notifications are implemented, we should also clear FCM token on logout to prevent receiving notifications when logged out
    // if (fireApi) {
    //   await _api.logout();
    // }
    await safeStorage.delete(key: 'token');
    await safeStorage.delete(key: 'userId');
  }
}
