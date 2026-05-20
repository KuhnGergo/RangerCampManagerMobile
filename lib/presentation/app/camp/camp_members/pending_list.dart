import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_members/pending_list_item.dart';
import 'package:mastercs_mobile/providers/data/camp_role_provider.dart';

class PendingList extends ConsumerWidget {
  final List<Member> pendingMembers;

  const PendingList({super.key, required this.pendingMembers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userRole = ref.watch(campRoleProvider).value;
    final isOwner = userRole == 'Owner';

    // Don't show if not owner or no pending members
    if (!isOwner || pendingMembers.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pending Join Requests',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Text(
              '${pendingMembers.length}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pendingMembers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12),
                child: PendingListItem(member: pendingMembers[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
