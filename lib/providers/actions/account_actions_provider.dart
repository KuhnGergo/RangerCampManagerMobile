import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/repositories/account_repository.dart';

final accountActionsProvider =
    AsyncNotifierProvider<AccountActionsProvider, void>(
      () => AccountActionsProvider(),
    );

class AccountActionsProvider extends AsyncNotifier<void> {
  late final AccountRepository repository = ref.read(accountRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> refreshMyAccount() async {
    try {
      state = const AsyncLoading();
      await repository.refreshMyAccount();
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Update account on server and local database
  Future<void> updateAccount({
    required String name,
    required String email,
    String? phoneNumber,
    String? profilePicture,
    String? emergencyContact,
  }) async {
    try {
      state = const AsyncLoading();
      await repository.updateAccount(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        profilePicture: profilePicture,
        emergencyContact: emergencyContact,
      );
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      state = const AsyncLoading();
      await repository.deleteAccount();
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}
