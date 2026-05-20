import 'package:flutter/material.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';
import 'package:mastercs_mobile/utils/chat_type_utils.dart';

class ChatCircle extends StatelessWidget {
  final ChatType type;
  final double size;
  final String? textColor;
  final bool highlighted;

  const ChatCircle({
    super.key,
    required this.type,
    this.size = 48.0,
    this.textColor,
    this.highlighted = false,
  });

  Color _getChatBorderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case ChatType.camp:
        return colorScheme.primary;
      case ChatType.staff:
        return colorScheme.primary;
      case ChatType.room:
        return ChatColorHelper.getFullColor(
          textColor,
          fallback: colorScheme.outline,
        );
      case ChatType.group:
        return ChatColorHelper.getFullColor(
          textColor,
          fallback: colorScheme.outline,
        );
      case ChatType.emptyCamp:
      case ChatType.emptyStaff:
      case ChatType.emptyRoom:
      case ChatType.emptyGroup:
        return colorScheme.outline;
      case ChatType.archived:
      case ChatType.archivedRoom:
      case ChatType.archivedGroup:
        return colorScheme.outline;
      default:
        return colorScheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getChatBorderColor(context);
    final isCampChat = type == ChatType.camp;

    // If type is provided, show an icon instead of initials
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: highlighted
            ? ChatColorHelper.getFullColor(textColor, fallback: borderColor)
            : Colors.transparent,
        border: Border.all(color: borderColor, width: isCampChat ? 3 : 2),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: CircleAvatar(
        backgroundColor: ChatColorHelper.getMediumColor(
          textColor,
          fallback: borderColor,
        ),
        child: Icon(
          ChatTypeUtils.getChatIcon(chatType: type),
          color: highlighted ? Colors.white : borderColor,
          size: size * 0.5,
        ),
      ),
    );
  }
}
