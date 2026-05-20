import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_bottom_sheet/chat_members_row.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_bottom_sheet/chat_members_screen.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/data/chat_members_family_provider.dart';

class ChatMembersSection extends ConsumerWidget {
  final Chat chat;

  const ChatMembersSection({super.key, required this.chat});

  void _openMembersScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ChatMembersScreen(chat: chat)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final membersAsync = ref.watch(chatMembersViewProvider(chat.remoteId));

    return membersAsync.when(
      data: (members) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openMembersScreen(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Members (${members.length})',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (members.isNotEmpty)
                      TextButton(
                        onPressed: () => _openMembersScreen(context),
                        child: const Text('See all'),
                      ),
                  ],
                ),
                if (members.isEmpty)
                  Text(
                    'No members in this chat.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ChatMembersRow(members: members, colorScheme: colorScheme),
              ],
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: ThreeDotLoadingIndicator(),
          ),
        ),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text('Failed to load members'),
      ),
    );
  }
}
