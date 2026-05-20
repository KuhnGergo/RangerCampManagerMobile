import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';
import 'package:mastercs_mobile/utils/chat_type_utils.dart';

class ChatTypeTag extends ConsumerWidget {
  final ChatType type;
  final String chatColor;

  const ChatTypeTag({super.key, required this.type, required this.chatColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use chat color if provided (for room/group), otherwise use default colors
    final backgroundColor = ChatColorHelper.getBackgroundColor(chatColor);

    final textColor = ChatColorHelper.getFullColor(chatColor);

    final icon = ChatTypeUtils.getChatIcon(chatType: type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            type.toString(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
