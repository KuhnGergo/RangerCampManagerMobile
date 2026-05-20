import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/user_dao.dart';
import 'package:mastercs_mobile/data/api/requests/user_api.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final userDao = ref.watch(userDaoProvider);
  final userApi = ref.watch(userApiProvider);
  return AccountRepository(userDao, userApi);
});

class AccountRepository {
  final UserDao _dao;
  final UserApi _api;

  AccountRepository(this._dao, this._api);

  /// Update current user account on server and local database
  Future<User?> updateAccount({
    required String name,
    required String email,
    String? phoneNumber,
    String? profilePicture,
    String? emergencyContact,
  }) async {
    try {
      // Update on server first
      final responseData = await _api.updateMyAccount(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        profilePicture: profilePicture,
        emergencyContact: emergencyContact,
      );

      // Update local database with server response
      final updatedUser = User(
        remoteId: responseData['id'],
        name: responseData['name'] ?? name,
        email: responseData['email'] ?? email,
        phoneNumber: responseData['phoneNumber'] ?? phoneNumber,
        profilePicturePath: responseData['profilePic'] ?? profilePicture,
        emergencyContact: responseData['emergencyContact'] ?? emergencyContact,
        createdAt: DateTime.now(),
      );

      await _dao.upsertUser(
        _dao.toCompanion(
          id: updatedUser.remoteId,
          name: updatedUser.name,
          email: updatedUser.email,
          profilePicturePath: updatedUser.profilePicturePath,
          phoneNumber: updatedUser.phoneNumber,
          emergencyContact: updatedUser.emergencyContact,
        ),
      );

      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      await _api.deleteMyAccount();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshMyAccount() async {
    try {
      final remoteUser = await _api.getMyAccount();
      await _dao.upsertUser(
        UsersCompanion.insert(
          remoteId: remoteUser['id'],
          name: remoteUser['name'],
          email: remoteUser['email'],
          profilePicturePath: Value(remoteUser['profilePic']),
          phoneNumber: Value(remoteUser['phoneNumber']),
          emergencyContact: Value(remoteUser['emergencyContact']),
        ),
      );
    } catch (e) {
      // Handle error silently, keep local data
      rethrow;
    }
  }
}
