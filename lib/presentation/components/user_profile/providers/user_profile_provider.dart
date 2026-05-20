import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/user_dao.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';
import 'package:mastercs_mobile/providers/data/chats_list_provider.dart';

/// Watched User (Drift model with email, phone, emergencyContact)
final profileUserProvider = StreamProvider.autoDispose.family<User?, String>((
  ref,
  userId,
) {
  return ref.read(userDaoProvider).watchUser(userId);
});

/// Watched Member (with online status, groupId, roomId, location, etc.)
final profileMemberProvider = StreamProvider.autoDispose
    .family<Member?, String>((ref, userId) {
      return ref.watch(campMembersListProvider.future).asStream().map((
        members,
      ) {
        return members.where((m) => m.userRemoteId == userId).firstOrNull;
      });
    });

/// Current user's Role enum
final myRoleProvider = Provider.autoDispose<Role?>((ref) {
  final userId = ref.read(authProvider.notifier).getUserId;
  if (userId == null) return null;

  final members = ref.watch(campMembersListProvider).value;
  if (members == null) return null;

  final me = members.where((m) => m.userRemoteId == userId).firstOrNull;
  if (me == null) return null;

  return Role.fromString(me.role);
});

/// The target member's group chat
final memberGroupChatProvider = Provider.autoDispose.family<Chat?, String>((
  ref,
  groupId,
) {
  final chats = ref.watch(chatsListProvider).value;
  if (chats == null) return null;

  return chats
      .where((c) => c.type == ChatType.group.toString() && c.typeId == groupId)
      .firstOrNull;
});

/// The target member's room chat
final memberRoomChatProvider = Provider.autoDispose.family<Chat?, String>((
  ref,
  roomId,
) {
  final chats = ref.watch(chatsListProvider).value;
  if (chats == null) return null;

  return chats
      .where((c) => c.type == ChatType.room.toString() && c.typeId == roomId)
      .firstOrNull;
});
