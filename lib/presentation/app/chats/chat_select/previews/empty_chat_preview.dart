import 'package:flutter/material.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/utils/chat_type_utils.dart';

/// Preview widget for empty/non-existent chats
/// Shows a placeholder UI indicating the chat is not yet created
class EmptyChatPreview extends StatelessWidget {
  final ChatType chatType;

  const EmptyChatPreview({super.key, required this.chatType});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Empty chat icon circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainerHighest.withAlpha(128),
                  border: Border.all(
                    color: colorScheme.outline.withAlpha(77),
                    width: 2,
                  ),
                ),
                child: Icon(
                  ChatTypeUtils.getChatIcon(chatType: chatType),
                  size: 30,
                  color: colorScheme.onSurface.withAlpha(102),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatType.label,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        color: colorScheme.onSurface.withAlpha(128),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: colorScheme.onSurface.withAlpha(70),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Not found.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(100),
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
