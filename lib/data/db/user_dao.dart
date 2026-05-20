import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/schema/app_database.dart';
import '../../core/schema/tables/users_table.dart';

part 'user_dao.g.dart';

final userDaoProvider = Provider<UserDao>(
  (ref) => UserDao(ref.read(databaseProvider)),
);

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  /// Convert data to UsersCompanion for database operations
  UsersCompanion toCompanion({
    required String id,
    required String name,
    required String email,
    String? profilePicturePath,
    String? phoneNumber,
    String? emergencyContact,
  }) {
    return UsersCompanion(
      remoteId: Value(id),
      name: Value(name),
      email: Value(email),
      profilePicturePath: Value(profilePicturePath),
      phoneNumber: Value(phoneNumber),
      emergencyContact: Value(emergencyContact),
    );
  }

  // ===== Create Operations =====

  Future<User?> getUserById(String id) {
    return (select(
      users,
    )..where((u) => u.remoteId.equals(id))).getSingleOrNull();
  }

  /// Update or Add existing user
  Future<bool> upsertUser(UsersCompanion user) async {
    final rowsAffected = await into(users).insertOnConflictUpdate(user);
    return rowsAffected > 0;
  }

  Future<void> upsertManyUsers(List<UsersCompanion> usersList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(users, usersList);
    });
  }

  Stream<User?> watchUser(String id) {
    return (select(
      users,
    )..where((u) => u.remoteId.equals(id))).watchSingleOrNull();
  }

  /// Watch all users
  Stream<List<User>> watchAllUsers() {
    return select(users).watch();
  }
}
