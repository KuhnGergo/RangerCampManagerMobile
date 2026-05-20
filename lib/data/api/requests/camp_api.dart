import 'package:mastercs_mobile/core/api/api.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the CampApi service
final campApiProvider = Provider<CampApi>((ref) {
  final client = ref.watch(httpClientProvider);
  final endpoints = ref.watch(endpointsProvider);
  return CampApi(client, endpoints);
});

/// API client for camp-related operations
class CampApi {
  final ApiHttpClient _client;
  final Endpoints _endpoints;

  CampApi(this._client, this._endpoints);

  /// Get user's camps from server
  Future<List<Map<String, dynamic>>> getMyCamps() async {
    final response = await _client.get(_endpoints.getMyCamps);
    final data = response.jsonOrThrow['data'];

    return data.cast<Map<String, dynamic>>();
  }

  /// Create a new camp
  Future<Map<String, dynamic>> createCamp({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    int? minGroupSize,
    String? joinCode,
  }) async {
    final response = await _client.post(
      _endpoints.createCamp,
      body: {
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (minGroupSize != null) 'minGroupSize': minGroupSize,
        if (joinCode != null) 'joinCode': joinCode,
      },
    );
    final campList = response.jsonOrThrow['data'] as List<dynamic>;
    return campList[0] as Map<String, dynamic>;
  }

  /// Join a camp by code
  Future<Map<String, dynamic>> joinCamp(String code) async {
    final response = await _client.post(_endpoints.joinCamp(code));
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Get specific camp details
  Future<Map<String, dynamic>> getCamp(String campId) async {
    final response = await _client.get(_endpoints.getCamp(campId));
    return response.jsonOrThrow['data'] as Map<String, dynamic>;
  }

  /// Update my camp details
  Future<void> updateCamp({
    required String campId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    int? minGroupSize,
    String? joinCode,
  }) async {
    final response = await _client.patch(
      _endpoints.updateCamp(campId),
      body: {
        if (name != null) 'name': name,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (minGroupSize != null) 'minGroupSize': minGroupSize,
        if (joinCode != null) 'joinCode': joinCode,
      },
    );
    response.throwIfError();
  }

  /// Delete my camp
  Future<void> deleteCamp(String campId) async {
    final response = await _client.delete(_endpoints.deleteCamp(campId));
    response.throwIfError();
  }

  /// Leave a camp
  Future<void> leaveCamp(String campId) async {
    final response = await _client.delete(_endpoints.leaveCamp(campId));
    response.throwIfError();
  }

  /// Download join QR code PNG bytes for a camp
  Future<Uint8List> downloadJoinQrCode(String campId) async {
    final response = await _client.get(
      _endpoints.downloadJoinQrCode(campId),
      headers: {'Accept': '*/*'},
    );
    response.throwIfError();
    return response.bodyBytes;
  }
}
