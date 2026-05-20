import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/actions/account_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/account_provider.dart';
import 'package:mastercs_mobile/repositories/image_repository.dart';

final imageActionsProvider = AsyncNotifierProvider<ImageActionsProvider, void>(
  () => ImageActionsProvider(),
);

/// Provider that exposes image-related actions to the UI layer.
///
/// Delegates all business logic to [ImageRepository].
/// Holds no image state itself — consumers obtain URLs from [ImageRepository]
/// or compute them directly (baseUrl + filename).
class ImageActionsProvider extends AsyncNotifier<void> {
  late final ImageRepository _repository = ref.read(imageRepositoryProvider);

  @override
  Future<void> build() async {}

  /// Upload a profile picture for the current user.
  ///
  /// Returns the full URL of the uploaded image.
  /// Throws on validation or network error.
  Future<String> uploadProfilePicture(File imageFile) async {
    state = const AsyncLoading();
    try {
      final url = await _repository.uploadProfilePicture(imageFile);

      await ref.read(accountActionsProvider.notifier).refreshMyAccount();

      state = const AsyncData(null);
      return url;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Delete the current user's profile picture.
  Future<void> deleteProfilePicture() async {
    state = const AsyncLoading();
    try {
      await _repository.deleteProfilePicture();

      // Clear filename from local DB
      final userId = ref.read(accountProvider).value?.remoteId;
      if (userId != null) {
        await _repository.clearProfilePicture(userId);
      }

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}
