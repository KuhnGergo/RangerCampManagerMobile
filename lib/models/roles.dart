import 'package:flutter/material.dart';
import 'package:mastercs_mobile/models/chat_types.dart';

enum Role {
  owner,
  staff,
  camper,
  pending;

  /// This is the display string used in the UI, not the logical string used in the database
  ///
  /// Localization should be applied to this string when used in the UI
  String get stringName {
    switch (this) {
      case Role.owner:
        return 'Owner';
      case Role.staff:
        return 'Staff';
      case Role.camper:
        return 'Camper';
      case Role.pending:
        return 'Pending';
    }
  }

  /// This is the logical string used in the database, not the display string
  /// Use [stringName] for display purposes and [fromString] for parsing from the database
  @override
  String toString() {
    switch (this) {
      case Role.owner:
        return 'Owner';
      case Role.staff:
        return 'Staff';
      case Role.camper:
        return 'Camper';
      case Role.pending:
        return 'Pending';
    }
  }

  /// This parses the logical string from the database into a Role enum case-insensitive.
  ///
  /// Use [stringName] for display purposes and toString for getting the logical string for the database
  static Role fromString(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'owner':
        return Role.owner;
      case 'staff':
        return Role.staff;
      case 'camper':
        return Role.camper;
      case 'pending':
        return Role.pending;
      default:
        throw ArgumentError('Invalid role string: $roleString');
    }
  }

  IconData get icon {
    switch (this) {
      case Role.owner:
        return Icons.star;
      case Role.staff:
        return Icons.security;
      case Role.camper:
        return Icons.person;
      case Role.pending:
        return Icons.hourglass_full;
    }
  }

  bool canManageChat(ChatType chatType) {
    if (this == Role.owner) return true;

    if (chatType == ChatType.camp) {
      return this == Role.owner;
    }

    return true;
  }
}
