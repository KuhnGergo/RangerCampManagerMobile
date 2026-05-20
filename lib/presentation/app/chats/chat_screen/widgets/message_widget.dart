import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/schema/tables/messages_table.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_screen/widgets/date_info_widget.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/message_status_icon.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_avatar_clickable.dart';

class MessageWidget extends StatelessWidget {
  final String content;
  final String senderName;
  final String? senderUserId;
  final String? senderImageFilename;
  final DateTime timestamp;
  final bool isMe;
  final String? meBubbleColor;
  final MessageStatus? messageStatus;
  final bool isSeenByOthers;
  final List<String> seenByNames;
  final bool showSeenIndicator;
  final bool shouldShowSenderName;
  final bool showTimestamp;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool canShowTimestampOnTap;
  final VoidCallback? onTap;

  const MessageWidget({
    super.key,
    required this.content,
    required this.senderName,
    this.senderUserId,
    this.senderImageFilename,
    required this.timestamp,
    required this.isMe,
    this.meBubbleColor,
    this.messageStatus,
    this.isSeenByOthers = false,
    this.seenByNames = const [],
    this.showSeenIndicator = false,
    this.shouldShowSenderName = true,
    this.showTimestamp = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.canShowTimestampOnTap = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ownBubbleColor = meBubbleColor != null
        ? ChatColorHelper.getBackgroundColor(meBubbleColor!)
        : colorScheme.primaryContainer;

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // Show timestamp centered above message when tapped
        if (showTimestamp) DateInfoWidget(timestamp: timestamp),

        // Show sender name and avatar above message if needed
        if (!isMe && shouldShowSenderName)
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              bottom: 4,
              top: showTimestamp ? 0 : 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (senderUserId != null) ...[
                  AccountAvatarClickable(
                    name: senderName,
                    userId: senderUserId!,
                    profilePictureFilename: senderImageFilename,
                    radius: 12,
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  senderName,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Message bubble
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(
                bottom: 2,
                left: 16,
                right: 16,
                top: (!isMe && shouldShowSenderName) || showTimestamp ? 0 : 4,
              ),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? ownBubbleColor
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: isMe
                      ? const Radius.circular(16)
                      : isFirstInGroup
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  topRight: isMe
                      ? isFirstInGroup
                            ? const Radius.circular(16)
                            : const Radius.circular(4)
                      : const Radius.circular(16),
                  bottomLeft: isMe
                      ? const Radius.circular(16)
                      : isLastInGroup
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? isLastInGroup
                            ? const Radius.circular(16)
                            : const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                content,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ),
        ),

        // Message status indicator under message
        if (isMe && messageStatus != null)
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 2),
            child: MessageStatusIcon(messageStatus: messageStatus),
          ),
      ],
    );
  }
}
