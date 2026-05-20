import 'package:mastercs_mobile/models/chat_category.dart';

/// Enum representing different chat types in the application
enum ChatType {
  camp,
  staff,
  room,
  group,
  emptyCamp,
  emptyStaff,
  emptyRoom,
  emptyGroup,
  archivedRoom,
  archivedGroup,
  archived,
  unknown;

  /// Converts a string type to ChatType enum
  static ChatType fromString(String type) {
    switch (type) {
      case 'Camp':
        return ChatType.camp;
      case 'Staff':
      case 'StaffChat':
        return ChatType.staff;
      case 'Room':
        return ChatType.room;
      case 'Group':
        return ChatType.group;
      case 'EmptyCamp':
        return ChatType.emptyCamp;
      case 'EmptyStaff':
        return ChatType.emptyStaff;
      case 'EmptyRoom':
        return ChatType.emptyRoom;
      case 'EmptyGroup':
        return ChatType.emptyGroup;
      case 'ArchivedRoom':
        return ChatType.archivedRoom;
      case 'ArchivedGroup':
        return ChatType.archivedGroup;
      case 'Archived':
        return ChatType.archived;
      default:
        return ChatType.unknown;
    }
  }

  @override
  String toString() {
    switch (this) {
      case ChatType.camp:
        return 'Camp';
      case ChatType.staff:
        return 'Staff';
      case ChatType.room:
        return 'Room';
      case ChatType.group:
        return 'Group';
      case ChatType.emptyCamp:
        return 'EmptyCamp';
      case ChatType.emptyStaff:
        return 'EmptyStaff';
      case ChatType.emptyRoom:
        return 'EmptyRoom';
      case ChatType.emptyGroup:
        return 'EmptyGroup';
      case ChatType.archivedRoom:
        return 'ArchivedRoom';
      case ChatType.archivedGroup:
        return 'ArchivedGroup';
      case ChatType.archived:
        return 'Archived';
      case ChatType.unknown:
        return 'Unknown';
    }
  }

  /// Returns the display label for the chat type
  ///
  /// This is used in the UI to show user-friendly names for each chat type
  ///
  /// Might change based on l10n localization in the future, but for now it's hardcoded
  String get label {
    switch (this) {
      case ChatType.camp:
        return 'Camp';
      case ChatType.staff:
        return 'Staff';
      case ChatType.room:
        return 'Room';
      case ChatType.group:
        return 'Group';
      case ChatType.emptyCamp:
        return 'Camp Chat';
      case ChatType.emptyStaff:
        return 'Staff Chat';
      case ChatType.emptyRoom:
        return 'Room Chat';
      case ChatType.emptyGroup:
        return 'Group Chat';
      case ChatType.archivedRoom:
        return 'Archived Room';
      case ChatType.archivedGroup:
        return 'Archived Group';
      case ChatType.archived:
        return 'Archived';
      case ChatType.unknown:
        return 'Chat';
    }
  }

  bool get isArchived =>
      this == ChatType.archived ||
      this == ChatType.archivedRoom ||
      this == ChatType.archivedGroup;

  bool get isEmpty =>
      this == ChatType.emptyCamp ||
      this == ChatType.emptyStaff ||
      this == ChatType.emptyRoom ||
      this == ChatType.emptyGroup;

  ChatCategory get category {
    switch (this) {
      case ChatType.camp:
      case ChatType.emptyCamp:
        return ChatCategory.camp;
      case ChatType.staff:
      case ChatType.emptyStaff:
        return ChatCategory.staff;
      case ChatType.room:
      case ChatType.emptyRoom:
        return ChatCategory.room;
      case ChatType.group:
      case ChatType.emptyGroup:
        return ChatCategory.group;
      case ChatType.archivedRoom:
        return ChatCategory.archivedRoom;
      case ChatType.archivedGroup:
        return ChatCategory.archivedGroup;
      case ChatType.archived:
        return ChatCategory.archived;
      case ChatType.unknown:
        return ChatCategory.other;
    }
  }
}
