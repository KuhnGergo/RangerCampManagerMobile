import 'package:flutter/material.dart';

enum ChatCategory {
  highlighted,
  camp,
  staff,
  room,
  group,
  archivedGroup,
  archivedRoom,
  archived,
  other;

  static String getLabel(ChatCategory category) {
    switch (category) {
      case ChatCategory.highlighted:
        return 'Highlighted';
      case ChatCategory.camp:
        return 'Camp';
      case ChatCategory.staff:
        return 'Staff';
      case ChatCategory.room:
        return 'Rooms';
      case ChatCategory.group:
        return 'Groups';
      case ChatCategory.archivedGroup:
        return 'Archived Groups';
      case ChatCategory.archivedRoom:
        return 'Archived Rooms';
      case ChatCategory.archived:
        return 'Archived Chats';
      case ChatCategory.other:
        return 'Other Chats';
    }
  }

  static Icon getIcon(ChatCategory category) {
    switch (category) {
      case ChatCategory.highlighted:
        return const Icon(Icons.star);
      case ChatCategory.camp:
        return const Icon(Icons.landscape_outlined);
      case ChatCategory.staff:
        return const Icon(Icons.security_outlined);
      case ChatCategory.room:
        return const Icon(Icons.chat_bubble_outline);
      case ChatCategory.group:
        return const Icon(Icons.group_outlined);
      case ChatCategory.archivedGroup:
        return const Icon(Icons.archive_outlined);
      case ChatCategory.archivedRoom:
        return const Icon(Icons.archive_outlined);
      case ChatCategory.archived:
        return const Icon(Icons.archive_outlined);
      case ChatCategory.other:
        return const Icon(Icons.chat_bubble_outline);
    }
  }
}
