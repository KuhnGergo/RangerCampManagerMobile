import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_role_provider.dart';
import 'package:mastercs_mobile/providers/location/all_members_with_location_provider.dart';

/// Filters [allMembersWithLocationProvider] by the current user's role:
/// - [Role.camper]: only members in the same group, plus staff and owner
/// - Any other role: all members (unfiltered)
final filteredMembersWithLocationProvider =
    Provider.autoDispose<AsyncValue<List<Member>>>((ref) {
      final allMembersAsync = ref.watch(allMembersWithLocationProvider);
      final roleAsync = ref.watch(campRoleProvider);

      return allMembersAsync.whenData((allMembers) {
        final roleString = roleAsync.maybeWhen(
          data: (r) => r,
          orElse: () => null,
        );

        if (roleString == null) return allMembers;

        final Role role;
        try {
          role = Role.fromString(roleString);
        } catch (_) {
          return allMembers;
        }

        if (role != Role.camper) return allMembers;

        // Campers see only their own group members + staff + owner.
        // The current user must always be present in the filtered result.
        final userId = ref.read(authProvider.notifier).getUserId;
        final membersAsync = ref.watch(campMembersListProvider);
        final currentMember = membersAsync.maybeWhen(
          data: (members) =>
              members.where((m) => m.userRemoteId == userId).firstOrNull,
          orElse: () => null,
        );
        final currentGroupId = currentMember?.groupId;

        return allMembers.where((member) {
          if (userId != null && member.userRemoteId == userId) return true;

          final Role memberRole;
          try {
            memberRole = Role.fromString(member.role);
          } catch (_) {
            return false;
          }
          if (memberRole == Role.owner || memberRole == Role.staff) return true;
          if (currentGroupId != null && member.groupId == currentGroupId) {
            return true;
          }
          return false;
        }).toList();
      });
    });
