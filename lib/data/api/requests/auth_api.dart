import 'package:mastercs_mobile/core/api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the AuthApi service
final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(httpClientProvider);
  return AuthApi(client, ref);
});

/// API client for authentication-related operations.
/// This class provides methods to interact with the authentication endpoints of the backend service.
class AuthApi {
  final ApiHttpClient _client;
  final Endpoints endpoints;

  AuthApi(this._client, Ref _ref) : endpoints = _ref.read(endpointsProvider);

  Future<bool> hasUser(String email) async {
    final response = await _client.getWithBody(
      endpoints.hasUser,
      auth: false,
      body: {'email': email},
    );
    return response.jsonOrThrow['data']['hasUser'] as bool;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      endpoints.login,
      auth: false,
      body: {'email': email, 'password': password},
    );

    return response.jsonOrThrow as Map<String, dynamic>;
  }

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    String? profilePicturePath,
    String? phoneNumber,
    String? emergencyContact,
  }) async {
    final body = {'email': email, 'password': password, 'name': username}
      ..addAll(phoneNumber != null ? {'phoneNumber': phoneNumber} : {})
      ..addAll(
        emergencyContact != null ? {'emergencyContact': emergencyContact} : {},
      )
      ..addAll(
        profilePicturePath != null ? {'profilePic': profilePicturePath} : {},
      );
    final response = await _client.post(
      endpoints.register,
      auth: false,
      body: body,
    );

    return response.jsonOrThrow as Map<String, dynamic>;
  }

  /// Logout the current user
  Future<void> logout() async {
    final response = await _client.post(endpoints.logout);
    response.throwIfError();
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    final response = await _client.post(
      endpoints.forgotPassword,
      body: {'email': email},
      auth: false,
    );
    response.throwIfError();
  }
}
