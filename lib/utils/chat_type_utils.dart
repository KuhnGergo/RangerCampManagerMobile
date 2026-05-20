import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/utils/color_utils.dart';

/// Utility class for chat type related operations
class ChatTypeUtils {
  /// Returns the appropriate icon for a given chat type
  static IconData getChatIcon({String? typeString, ChatType? chatType}) {
    final type = typeString != null
        ? ChatType.fromString(typeString)
        : chatType;
    if (type == null) {
      throw ArgumentError('Either typeString or chatType must be provided');
    }
    switch (type) {
      case ChatType.camp:
      case ChatType.emptyCamp:
        return Icons.landscape_outlined;
      case ChatType.staff:
      case ChatType.emptyStaff:
        return Icons.security;
      case ChatType.room:
      case ChatType.archivedRoom:
        return Icons.meeting_room;
      case ChatType.emptyRoom:
        return Icons.meeting_room_outlined;
      case ChatType.group:
      case ChatType.archivedGroup:
        return Icons.groups;
      case ChatType.emptyGroup:
        return Icons.groups_outlined;
      case ChatType.archived:
        return Icons.archive;
      case ChatType.unknown:
        return Icons.chat;
    }
  }

  static Color getHighlightedColor(Chat chat, ColorScheme colorScheme) {
    final chatType = ChatType.fromString(chat.type);
    switch (chatType) {
      case ChatType.camp:
      case ChatType.emptyCamp:
        return colorScheme.primaryContainer;
      case ChatType.staff:
      case ChatType.emptyStaff:
        return colorScheme.primaryContainer;
      case ChatType.room:
      case ChatType.emptyRoom:
        return ColorUtils.parseColor(
          chat.color,
          fallback: colorScheme.primaryContainer,
        ).withAlpha(0x4D);
      case ChatType.group:
      case ChatType.emptyGroup:
        return ColorUtils.parseColor(
          chat.color,
          fallback: colorScheme.primaryContainer,
        ).withAlpha(0x4D);
      case ChatType.archivedRoom:
      case ChatType.archivedGroup:
      case ChatType.archived:
        return ColorUtils.parseColor(
          chat.color,
          fallback: colorScheme.primaryContainer,
        ).withAlpha(0x4D);
      case ChatType.unknown:
        return colorScheme.surfaceContainerHighest;
    }
  }
}
