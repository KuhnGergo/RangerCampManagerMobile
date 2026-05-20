import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/user_dao.dart';
import 'package:mastercs_mobile/data/api/requests/user_api.dart';
import 'package:mastercs_mobile/data/db/member_to_camp_dao.dart';
import 'package:mastercs_mobile/data/db/user_payment_dao.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final userDao = ref.watch(userDaoProvider);
  final memberDao = ref.watch(memberToCampDaoProvider);
  final userApi = ref.watch(userApiProvider);
  final userPaymentDao = ref.watch(userPaymentDaoProvider);
  final db = ref.watch(databaseProvider);

  return MemberRepository(userDao, memberDao, userApi, userPaymentDao, db);
});

class MemberRepository {
  final UserDao _userDao;
  final MemberDao _memberDao;
  final UserApi _api;
  final UserPaymentDao _userPaymentDao;
  final AppDatabase _db;

  MemberRepository(
    this._userDao,
    this._memberDao,
    this._api,
    this._userPaymentDao,
    this._db,
  );

  Future<void> refreshCampMembers(String campId) async {
    try {
      // fetch merged data from api
      final remoteUsers = await _api.getUsersByCamp(campId);

      // separate user data
      final usersCompanions = remoteUsers.map((remoteUser) {
        return _userDao.toCompanion(
          id: remoteUser['id'],
          name: remoteUser['name'],
          email: remoteUser['email'],
          profilePicturePath: remoteUser['profilePicture'],
          phoneNumber: remoteUser['phoneNumber'],
          emergencyContact: remoteUser['emergencyContact'],
        );
      }).toList();

      // separate member data
      final memberCompanions = remoteUsers.map((remoteUser) {
        return _memberDao.toCompanion(
          campRemoteId: campId,
          userRemoteId: remoteUser['id'],
          groupId: remoteUser['groupId'],
          roomId: remoteUser['roomId'],
          role: remoteUser['role'],
        );
      }).toList();

      // separate payment data
      final paymentCompanions = remoteUsers.expand((remoteUser) {
        final payments = remoteUser['payments'] as List<dynamic>;
        return payments.map((payment) {
          return _userPaymentDao.toCompanion(
            userRemoteId: remoteUser['id'],
            paymentRemoteId: payment['id'],
            isPaid: payment['isPaid'],
          );
        });
      }).toList();

      // upsert data into local db, transaction triggers invalidation only once
      await _db.transaction(() async {
        await _userDao.upsertManyUsers(usersCompanions);
        await _memberDao.setMembersToCamp(memberCompanions);
        await _userPaymentDao.upsertManyUserPayments(paymentCompanions);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptMember(String campId, String userId) async {
    await _api.updateMemberRole(campId, userId, 'Camper');
    await _memberDao.updateMember(id: userId, campId: campId, role: 'Camper');
  }

  Future<void> updateRole(String campId, String userId, String newRole) async {
    await _api.updateMemberRole(campId, userId, newRole);
    await _memberDao.updateMember(id: userId, campId: campId, role: newRole);
  }

  Future<void> removeMember(String campId, String userId) async {
    await _api.removeMember(campId, userId);
    await _memberDao.removeMember(userId, campId);
  }

  // delete all members of a camp from local db
  Future<void> deleteMembersOfCamp(String campId) async {
    await _memberDao.deleteMembersByCamp(campId);
  }
}
