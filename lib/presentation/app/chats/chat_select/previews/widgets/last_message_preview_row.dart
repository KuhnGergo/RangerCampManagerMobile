import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_message.dart';
import 'package:mastercs_mobile/providers/data/account_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';
import 'package:mastercs_mobile/utils/time_utils.dart';

class LastMessagePreviewRow extends ConsumerWidget {
  final Chat chat;
  final ChatMessage? lastMessage;
  final Color textColor;
  final Color subtleTextColor;
  final Color highlightTextColor;

  const LastMessagePreviewRow({
    super.key,
    required this.chat,
    required this.lastMessage,
    required this.textColor,
    required this.subtleTextColor,
    required this.highlightTextColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final currentUserId = ref.watch(accountProvider).asData?.value?.remoteId;
    final members =
        ref.watch(campMembersListProvider).asData?.value ?? const [];

    final messageText = lastMessage?.text ?? '';
    final messageCreatedAt = lastMessage?.createdAt;
    final timeSince = formatTimeSince(
      messageCreatedAt ?? chat.lastMessageAt ?? chat.createdAt,
    );
    final isUnread =
        messageCreatedAt != null &&
        (chat.lastSeenAt == null || messageCreatedAt.isAfter(chat.lastSeenAt!));

    String? senderName;
    if (lastMessage == null) {
      senderName = null;
    } else if (lastMessage!.userRemoteId == currentUserId) {
      senderName = 'You';
    } else {
      for (final member in members) {
        if (member.userRemoteId == lastMessage!.userRemoteId) {
          senderName = member.name;
          break;
        }
      }
    }

    final contentStyle = textTheme.bodyMedium?.copyWith(
      color: isUnread ? highlightTextColor : textColor,
      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
    );
    final timeStyle = textTheme.bodySmall?.copyWith(
      color: subtleTextColor,
      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            senderName != null ? '$senderName: $messageText' : messageText,
            style: contentStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (timeSince.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(timeSince, style: timeStyle),
        ],
      ],
    );
  }
}
