import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_message.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/widgets/chat_circle.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/previews/widgets/last_message_preview_row.dart';
import 'package:mastercs_mobile/utils/chat_type_utils.dart';

// Types used for chat preview:
// - Room thats not selected
// - Group thats not selected
// - Archived chats
class ChatPreview extends ConsumerWidget {
  final Chat chat;
  final ChatMessage? lastMessage;
  final bool highlighted;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatPreview({
    super.key,
    required this.chat,
    this.lastMessage,
    this.onTap,
    this.onLongPress,
    this.highlighted = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final containerColor = highlighted
        ? ChatTypeUtils.getHighlightedColor(chat, colorScheme)
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        color: containerColor,
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: highlighted
                ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0)
                : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ChatCircle(
                  type: ChatType.fromString(chat.type),
                  highlighted: highlighted,
                  textColor: chat.color,
                  size: 60.0,
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
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: colorScheme.onSurface.withAlpha(0x80),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ChatType.fromString(chat.type).label,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withAlpha(0x80),
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
                              textColor: colorScheme.onSurface.withAlpha(0x99),
                              subtleTextColor: colorScheme.onSurface.withAlpha(
                                0x80,
                              ),
                              highlightTextColor: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
