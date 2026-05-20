import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/db/member_to_camp_dao.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/providers/data/online_users_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

final campMembersListProvider = StreamProvider.autoDispose<List<Member>>((ref) {
  final campId = ref
      .watch(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  if (campId == null) {
    return Stream.value([]);
  }

  final controller = StreamController<List<Member>>();

  // Watch members from database
  ref.listen(
    StreamProvider.autoDispose(
      (ref) => ref.read(memberToCampDaoProvider).watchMembersByCamp(campId),
    ),
    (previous, next) {
      _updateMembers(ref, controller);
    },
  );

  // Watch online users changes
  ref.listen(onlineUsersProvider, (previous, next) {
    _updateMembers(ref, controller);
  });

  // Initial update
  _updateMembers(ref, controller);

  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});

void _updateMembers(Ref ref, StreamController<List<Member>> controller) async {
  final campId = ref
      .read(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  if (campId == null) {
    if (!controller.isClosed) {
      controller.add([]);
    }
    return;
  }

  // Get members from database stream
  final membersStream = ref
      .read(memberToCampDaoProvider)
      .watchMembersByCamp(campId);
  final onlineUsers = ref.read(onlineUsersProvider);

  // Listen to the first emission
  membersStream.first.then((members) {
    // Merge with online status
    final updatedMembers = members.map((member) {
      final onlineUser = onlineUsers[member.userRemoteId];
      return member.copyWith(
        isOnline: onlineUser?.isOnline ?? false,
        lastSeenAt: onlineUser?.lastSeenAt,
      );
    }).toList();

    if (!controller.isClosed) {
      controller.add(updatedMembers);
    }
  });
}
