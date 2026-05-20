import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api.dart';
import 'package:mastercs_mobile/data/api/requests/image_api.dart';
import 'package:mastercs_mobile/data/db/user_dao.dart';
import 'package:mastercs_mobile/repositories/account_repository.dart';

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  final api = ref.watch(imageApiProvider);
  final userDao = ref.watch(userDaoProvider);
  final apiConfig = ref.watch(apiConfigProvider);
  final accountRepository = ref.watch(accountRepositoryProvider);
  return ImageRepository(
    api: api,
    userDao: userDao,
    apiConfig: apiConfig,
    accountRepository: accountRepository,
  );
});

/// Repository for managing profile picture operations.
///
/// - Upload: validates, sends binary, persists filename in local DB,
///   returns the assembled full URL.
/// - Delete: removes from server and clears filename in local DB.
/// - GetUrl: reads filename from local DB and assembles the full URL.
///   (no network call — images are static files at server root)
class ImageRepository {
  final ImageApi api;
  final UserDao userDao;
  final AccountRepository accountRepository;
  final ApiConfig apiConfig;

  ImageRepository({
    required this.api,
    required this.userDao,
    required this.apiConfig,
    required this.accountRepository,
  });

  /// Upload a profile picture for the current user.
  ///
  /// Validates size (≤ 5 MB) and format (jpg/jpeg/png), sends as
  /// application/octet-stream, persists the returned filename in the
  /// local DB, and returns the assembled full URL.
  ///
  /// Throws [ApiException] on validation or server error.
  Future<String> uploadProfilePicture(File imageFile) async {
    // Validate file size (5 MB max)
    final fileSize = await imageFile.length();
    if (fileSize > 5 * 1024 * 1024) {
      throw ApiException(
        statusCode: 400,
        message: 'Image size must be less than 5 MB',
      );
    }

    // Validate format
    final extension = imageFile.path.split('.').last.toLowerCase();
    if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
      throw ApiException(
        statusCode: 400,
        message: 'Only JPEG and PNG images are supported',
      );
    }

    final response = await api.uploadProfilePicture(imageFile);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        statusCode: response.statusCode,
        message:
            errorBody['message'] as String? ??
            'Failed to upload profile picture',
      );
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final filename = responseBody['profilePic'] as String? ?? '';

    return buildUrl(filename);
  }

  /// Persist the filename returned by [uploadProfilePicture] into the local DB.
  ///
  /// Must be called immediately after [uploadProfilePicture] by the provider
  /// which knows the current user's ID.
  Future<void> persistProfilePicture(String userId, String filename) async {
    final existing = await userDao.getUserById(userId);
    if (existing == null) return;
    await userDao.upsertUser(
      userDao.toCompanion(
        id: existing.remoteId,
        name: existing.name,
        email: existing.email,
        profilePicturePath: filename,
        phoneNumber: existing.phoneNumber,
        emergencyContact: existing.emergencyContact,
      ),
    );
  }

  /// Delete the current user's profile picture from the server.
  ///
  /// Throws [ApiException] on failure.
  Future<void> deleteProfilePicture() async {
    final response = await api.deleteProfilePicture();

    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 203) {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        statusCode: response.statusCode,
        message:
            errorBody['message'] as String? ??
            'Failed to delete profile picture',
      );
    }
  }

  /// Clear the profile picture filename in the local DB for [userId].
  Future<void> clearProfilePicture(String userId) async {
    final existing = await userDao.getUserById(userId);
    if (existing == null) return;
    await userDao.upsertUser(
      userDao.toCompanion(
        id: existing.remoteId,
        name: existing.name,
        email: existing.email,
        profilePicturePath: null,
        phoneNumber: existing.phoneNumber,
        emergencyContact: existing.emergencyContact,
      ),
    );
  }

  /// Build the full public URL for a profile picture filename.
  ///
  /// Extracts the server base URL (without /api/v0 path) from apiConfig.baseUrl
  /// and appends the filename.
  String buildUrl(String filename) {
    // Normalize Windows backslashes to forward slashes (don't strip them)
    final name = filename.replaceAll('\\', '/').replaceAll('/', '');
    // Parse the API base URL and extract just scheme://host:port
    final uri = Uri.parse(apiConfig.baseUrl);
    final serverBaseUrl =
        '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
    return '$serverBaseUrl/$name';
  }
}
