import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api.dart';

final userApiProvider = Provider<UserApi>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final endpoints = ref.watch(endpointsProvider);
  return UserApi(httpClient, endpoints);
});

class UserApi {
  final ApiHttpClient _client;
  final Endpoints _endpoints;

  UserApi(this._client, this._endpoints);

  // ===== Account Operations (for current authenticated user) =====

  /// Get current user account details from server
  /// [userId] is optional and used by mock API to look up user after app restart
  Future<Map<String, dynamic>> getMyAccount({String? userId}) async {
    final response = await _client.get(_endpoints.myAccount);
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Update current user account details on server
  Future<Map<String, dynamic>> updateMyAccount({
    required String name,
    required String email,
    String? phoneNumber,
    String? profilePicture,
    String? emergencyContact,
  }) async {
    final response = await _client.patch(
      _endpoints.updateMyAccount,
      body: {
        'name': name,
        'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (profilePicture != null) 'profilePicturePath': profilePicture,
        if (emergencyContact != null) 'emergencyContact': emergencyContact,
      },
    );
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Delete current user account
  Future<void> deleteMyAccount() async {
    final response = await _client.delete(_endpoints.deleteMyAccount);
    response.throwIfError();
  }

  // ===== Camp Member Operations =====

  Future<void> updateMemberRole(
    String campId,
    String userId,
    String newRole,
  ) async {
    final response = await _client.patch(
      _endpoints.updateMemberRole(campId, userId),
      body: {'role': newRole},
    );
    response.throwIfError();
  }

  Future<void> removeMember(String campId, String userId) async {
    final response = await _client.delete(
      _endpoints.removeMember(campId, userId),
    );
    response.throwIfError();
  }

  /// Get users by camp ID
  Future<List<Map<String, dynamic>>> getUsersByCamp(String campId) async {
    final response = await _client.get(_endpoints.getUsersByCamp(campId));
    return (response.jsonOrThrow['data'] as List).cast<Map<String, dynamic>>();
  }
}
