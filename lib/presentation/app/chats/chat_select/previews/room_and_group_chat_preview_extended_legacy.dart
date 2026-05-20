import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_message.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/widgets/chat_circle.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/chat_action_button.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_actions_handler.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';
import 'package:mastercs_mobile/presentation/components/join_code/join_code_card.dart';
import 'package:mastercs_mobile/utils/time_utils.dart';

/// Preview card for Room and Group chats
///
/// Shows colored header, last message, and action buttons
///
/// [Deprecated] This widget is now replaced by a clean, chat focused design in RoomAndGroupChatPreview.
///
/// This extended version with action buttons is no longer needed and will be removed in a future release.
@Deprecated('Use RoomAndGroupChatPreview instead')
class RoomAndGroupChatPreviewExtended extends ConsumerWidget {
  final Chat chat;
  final ChatMessage? lastMessage;
  final ChatActionsHandler actionsHandler;

  const RoomAndGroupChatPreviewExtended({
    super.key,
    required this.chat,
    this.lastMessage,
    required this.actionsHandler,
  });

  bool get isGroup => ChatType.fromString(chat.type) == ChatType.group;
  bool get isRoom => ChatType.fromString(chat.type) == ChatType.room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final lastMessageText = lastMessage?.text ?? '';
    final timeSince = formatTimeSince(
      lastMessage?.createdAt ?? chat.lastMessageAt ?? chat.createdAt,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Room header with color indicator
          Ink(
            decoration: BoxDecoration(
              color: ChatColorHelper.getBackgroundColor(chat.color),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              onTap: () {
                actionsHandler.openChat(context, chat);
              },
              onLongPress: () => actionsHandler.showBottomSheet(
                context,
                ref,
                chat,
                selected: true,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ChatCircle(
                      type: ChatType.fromString(chat.type),
                      textColor: chat.color,
                      size: 60,
                      highlighted: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  chat.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: ChatColorHelper.getAccentColor(
                                  chat.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ChatType.fromString(chat.type).label,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: ChatColorHelper.getAccentColor(
                                        chat.color,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lastMessageText,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withAlpha(
                                      0x99,
                                    ),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (timeSince.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  timeSince,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withAlpha(
                                      0x80,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => actionsHandler.showBottomSheet(
                        context,
                        ref,
                        chat,
                        selected: true,
                      ),
                      icon: Icon(Icons.menu),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),

          // Details section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Join code
                if (chat.joinCode != null)
                  JoinCodeCard(
                    joinCode: chat.joinCode!,
                    hasChangeAction: true,
                    hasCopyAction: true,
                  ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    ChatActionButton(
                      onPressed: () => actionsHandler.showCreateDialog(
                        context,
                        isGroup: isGroup,
                      ),
                      icon: Icons.add,
                      label: 'Create',
                    ),
                    const SizedBox(width: 8),
                    ChatActionButton(
                      onPressed: () => actionsHandler.showJoinDialog(
                        context,
                        ref,
                        isGroup: isGroup,
                      ),
                      icon: Icons.sync_alt,
                      label: 'Switch',
                    ),
                    if (!isGroup) ...[
                      const SizedBox(width: 8),
                      ChatActionButton(
                        onPressed: () => actionsHandler.handleLeave(
                          context,
                          ref,
                          isGroup: isGroup,
                          chatId: chat.typeId ?? '',
                        ),
                        icon: Icons.exit_to_app,
                        label: 'Leave',
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                    ],
                  ],
                ),
                if (isGroup) ...[
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      ChatActionButton(
                        onPressed: () => actionsHandler.handleLeave(
                          context,
                          ref,
                          isGroup: isGroup,
                          chatId: chat.typeId ?? '',
                        ),
                        icon: Icons.stop,
                        label: 'End',
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
