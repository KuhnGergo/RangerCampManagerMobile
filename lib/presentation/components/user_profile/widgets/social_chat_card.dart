import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_screen/chat_screen.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/widgets/chat_circle.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_actions_handler.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';

/// A rich card displaying a chat's name and color with Manage and Go to Chat actions.
class SocialChatCard extends ConsumerWidget {
  final Chat chat;
  final String label;
  final IconData icon;
  final bool isSelected;

  const SocialChatCard({
    super.key,
    required this.chat,
    required this.label,
    required this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    void goToChat() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
      );
    }

    void manageChat() {
      ChatActionsHandler().showBottomSheet(
        context,
        ref,
        chat,
        selected: isSelected,
      );
    }

    return Material(
      color: ChatColorHelper.getBackgroundColor(chat.color),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: goToChat,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            children: [
              ChatCircle(
                type: ChatType.fromString(chat.type),
                textColor: chat.color,
                size: 36,
                highlighted: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      chat.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: manageChat, icon: Icon(Icons.menu)),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
