import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_members/staff_list.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_members/camper_list.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_members/pending_list.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';

class CampMembersOverview extends ConsumerWidget {
  const CampMembersOverview({super.key});

  Member? _getOwner(List<Member> members) {
    try {
      return members.firstWhere((m) => m.role == 'Owner');
    } catch (e) {
      return null;
    }
  }

  List<Member> _getStaff(List<Member> members) {
    return members.where((m) => m.role == 'Staff').toList();
  }

  List<Member> _getCampers(List<Member> members) {
    return members.where((m) => m.role == 'Camper').toList();
  }

  List<Member> _getPending(List<Member> members) {
    return members.where((m) => m.role == 'Pending').toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campMembersAsync = ref.watch(campMembersListProvider);

    return campMembersAsync.when(
      data: (members) {
        final owner = _getOwner(members);
        final staff = _getStaff(members);
        final campers = _getCampers(members);
        final pending = _getPending(members);

        if (owner == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('No camp data available'),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Staff List (Owner + Staff)
              StaffList(owner: owner, staff: staff),
              SizedBox(height: 16),

              // Campers List
              CamperList(campers: campers),
              SizedBox(height: 16),

              // Pending Members List (only visible to owner)
              PendingList(pendingMembers: pending),
            ],
          ),
        );
      },
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ThreeDotLoadingIndicator(),
        ),
      ),
      error: (error, stack) => Center(child: SizedBox.shrink()),
    );
  }
}
