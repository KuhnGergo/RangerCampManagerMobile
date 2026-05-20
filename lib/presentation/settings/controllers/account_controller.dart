import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/actions/image_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/account_provider.dart';
import 'package:mastercs_mobile/repositories/account_repository.dart';

final accountControllerProvider =
    AsyncNotifierProvider<AccountController, void>(() => AccountController());

class AccountController extends AsyncNotifier<void> {
  late final account = ref.read(accountProvider);

  @override
  Future<void> build() async {}

  /// Update profile picture path
  Future<void> updateProfilePicture(String? newPath) async {
    final currentUser = account.value;
    if (currentUser == null) return;

    // Update profile images cache
    final profileImagesNotifier = ref.read(imageActionsProvider.notifier);
    if (newPath != null) {
      final file = File(newPath);
      if (await file.exists()) {
        profileImagesNotifier.uploadProfilePicture(file);
      }
    } else {
      profileImagesNotifier.deleteProfilePicture();
    }

    // Update local state immediately for responsive UI
    currentUser.copyWith(profilePicturePath: Value(newPath));
    state = AsyncData(null);

    // Update in database
    try {
      final repository = ref.read(accountRepositoryProvider);
      await repository.updateAccount(
        name: currentUser.name,
        email: currentUser.email,
        profilePicture: newPath,
      );
    } catch (e) {
      // Revert on error
      state = AsyncData(null);
      rethrow;
    }
  }
}
