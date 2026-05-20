import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_message.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/previews/widgets/last_message_preview_row.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/widgets/chat_circle.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_actions_handler.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';

/// Preview card for Room and Group chats
/// Shows colored header, last message, and action buttons
class RoomAndGroupChatPreview extends ConsumerWidget {
  final Chat chat;
  final ChatMessage? lastMessage;
  final ChatActionsHandler actionsHandler;

  const RoomAndGroupChatPreview({
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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Material(
            color: ChatColorHelper.getBackgroundColor(chat.color),
            borderRadius: const BorderRadius.all(Radius.circular(16)),

            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
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
                                child: LastMessagePreviewRow(
                                  chat: chat,
                                  lastMessage: lastMessage,
                                  textColor: colorScheme.onSurface.withAlpha(
                                    0x99,
                                  ),
                                  subtleTextColor: colorScheme.onSurface
                                      .withAlpha(0x80),
                                  highlightTextColor: colorScheme.onSurface,
                                ),
                              ),
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
        ],
      ),
    );
  }
}
