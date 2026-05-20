import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import '../../core/schema/app_database.dart';
import '../../core/schema/tables/member_to_camp_table.dart';
import '../../core/schema/tables/users_table.dart';

part 'member_to_camp_dao.g.dart';

final memberToCampDaoProvider = Provider<MemberDao>(
  (ref) => MemberDao(ref.read(databaseProvider)),
);

@DriftAccessor(tables: [MemberToCamp, Users])
class MemberDao extends DatabaseAccessor<AppDatabase> with _$MemberDaoMixin {
  MemberDao(super.db);

  MemberToCampCompanion toCompanion({
    required String campRemoteId,
    required String userRemoteId,
    required String role,
    String? groupId,
    String? roomId,
  }) {
    return MemberToCampCompanion(
      campRemoteId: Value(campRemoteId),
      userRemoteId: Value(userRemoteId),
      role: Value(role),
      groupId: Value(groupId),
      roomId: Value(roomId),
    );
  }

  /// Update or Add existing member-to-camp relationship
  Future<bool> upsertMemberToCamp(MemberToCampCompanion member) async {
    final rowsAffected = await into(
      memberToCamp,
    ).insertOnConflictUpdate(member);
    return rowsAffected > 0;
  }

  /// Update
  Future<bool> updateMember({
    required String id,
    required String campId,
    String? role,
    String? groupId,
    String? roomId,
  }) async {
    final updateCompanion = MemberToCampCompanion(
      role: role != null ? Value(role) : const Value.absent(),
      groupId: groupId != null ? Value(groupId) : const Value.absent(),
      roomId: roomId != null ? Value(roomId) : const Value.absent(),
    );

    final rowsAffected =
        await (update(memberToCamp)..where(
              (m) => m.userRemoteId.equals(id) & m.campRemoteId.equals(campId),
            ))
            .write(updateCompanion);

    return rowsAffected > 0;
  }

  Future<void> setMembersToCamp(List<MemberToCampCompanion> membersList) async {
    // Only delete members that are not in the new list
    final campId = membersList.first.campRemoteId.value;
    final userIdList = membersList.map((e) => e.userRemoteId.value).toList();
    (delete(memberToCamp)..where(
          (m) =>
              m.campRemoteId.equals(campId) &
              m.userRemoteId.isNotIn(userIdList),
        ))
        .go();

    // Insert or update members
    await batch((batch) {
      batch.insertAllOnConflictUpdate(memberToCamp, membersList);
    });
  }

  Stream<List<Member>> watchMembersByCamp(String campId) {
    return (select(memberToCamp).join([
      innerJoin(users, users.remoteId.equalsExp(memberToCamp.userRemoteId)),
    ])..where(memberToCamp.campRemoteId.equals(campId))).map((row) {
      final member = row.readTable(memberToCamp);
      final user = row.readTable(users);

      return Member(
        userRemoteId: user.remoteId,
        name: user.name,
        profilePicture: user.profilePicturePath,
        role: member.role,
        groupId: member.groupId,
        roomId: member.roomId,
      );
    }).watch();
  }

  Future<void> removeMember(String userId, String campId) async {
    await (delete(memberToCamp)..where(
          (m) => m.userRemoteId.equals(userId) & m.campRemoteId.equals(campId),
        ))
        .go();
  }

  Future<void> deleteMembersByCamp(String campId) async {
    await (delete(
      memberToCamp,
    )..where((m) => m.campRemoteId.equals(campId))).go();
  }
}
