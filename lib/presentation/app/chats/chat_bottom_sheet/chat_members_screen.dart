import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/presentation/components/member/member_info_item.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';
import 'package:mastercs_mobile/providers/data/chat_members_family_provider.dart';

class ChatMembersScreen extends ConsumerWidget {
  final Chat chat;

  const ChatMembersScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatMembersAsync = ref.watch(chatMembersViewProvider(chat.remoteId));
    final campMembersAsync = ref.watch(campMembersListProvider);

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chat.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Text(
            'Members',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: chatMembersAsync.when(
              data: (chatMembers) {
                return campMembersAsync.when(
                  data: (campMembers) {
                    final chatMemberIds = chatMembers
                        .map((member) => member.userRemoteId)
                        .toSet();

                    final sortedMembers =
                        campMembers
                            .where(
                              (member) =>
                                  chatMemberIds.contains(member.userRemoteId),
                            )
                            .toList()
                          ..sort(_compareMembers);

                    if (sortedMembers.isEmpty) {
                      return const Center(
                        child: Text('No members in this chat.'),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: sortedMembers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final member = sortedMembers[index];

                        return MemberInfoItem(
                          member: member,
                          showGroup: true,
                          showRoom: true,
                          showRole: true,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: ThreeDotLoadingIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                );
              },
              loading: () => const Center(child: ThreeDotLoadingIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  static int _compareMembers(Member left, Member right) {
    final roleComparison = _roleRank(
      left.role,
    ).compareTo(_roleRank(right.role));
    if (roleComparison != 0) {
      return roleComparison;
    }

    return left.name.toLowerCase().compareTo(right.name.toLowerCase());
  }

  static int _roleRank(String role) {
    switch (Role.fromString(role)) {
      case Role.owner:
        return 0;
      case Role.staff:
        return 1;
      case Role.camper:
        return 2;
      case Role.pending:
        return 3;
    }
  }
}
