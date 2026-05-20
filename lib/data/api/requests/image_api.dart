import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mastercs_mobile/core/api/api_provider.dart';
import 'package:mastercs_mobile/data/api/endpoints.dart';
import 'package:mastercs_mobile/core/api/http_client.dart';

final imageApiProvider = Provider<ImageApi>((ref) {
  final client = ref.watch(httpClientProvider);
  final endpoints = ref.watch(endpointsProvider);
  return ImageApi(client: client, endpoints: endpoints);
});

/// API service for uploading and deleting profile images.
/// The profile picture URL is assembled client-side from the base URL and filename.
class ImageApi {
  final ApiHttpClient client;
  final Endpoints endpoints;

  ImageApi({required this.client, required this.endpoints});

  /// Upload a profile picture via binary octet-stream.
  /// Endpoint: POST /me/profilePicture
  /// Returns [http.Response] with `profilePic` filename in JSON body.
  Future<http.Response> uploadProfilePicture(File imageFile) async {
    final route = endpoints.profilePictureUpload;
    return await client.uploadBinary(route, file: imageFile, auth: true);
  }

  /// Delete the current user's profile picture.
  /// Endpoint: DELETE /me/profilePicture
  Future<http.Response> deleteProfilePicture() async {
    final route = endpoints.profilePictureDelete;
    return await client.delete(route, auth: true);
  }
}
