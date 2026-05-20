import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';

final campRoleProvider = StreamProvider.autoDispose<String?>((ref) {
  final userId = ref.read(authProvider.notifier).getUserId;

  if (userId == null) {
    return Stream.value(null);
  }

  return ref.watch(campMembersListProvider.future).asStream().map((members) {
    final currentUserMember = members.firstWhere(
      (member) => member.userRemoteId == userId,
      orElse: () => null as dynamic,
    );
    return currentUserMember.role;
  });
});
