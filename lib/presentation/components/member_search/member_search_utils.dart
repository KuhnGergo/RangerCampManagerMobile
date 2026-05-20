import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/member.dart';

/// Utility functions for filtering and searching members
class MemberSearchUtils {
  /// Filter members based on a search query
  ///
  /// The search is case-insensitive and matches against:
  /// - Member name
  /// - Group name (from chats)
  /// - Room name (from chats)
  /// - Role
  ///
  /// Returns all members if the query is empty
  static List<Member> filterMembers(
    List<Member> members,
    String query,
    List<Chat> chats,
  ) {
    if (query.isEmpty) {
      return members;
    }

    final lowerQuery = query.toLowerCase();

    return members.where((member) {
      return _matchesMember(member, lowerQuery, chats);
    }).toList();
  }

  /// Check if a member matches the search query
  static bool _matchesMember(
    Member member,
    String lowerQuery,
    List<Chat> chats,
  ) {
    // Match against member name
    if (member.name.toLowerCase().contains(lowerQuery)) {
      return true;
    }

    // Match against group name
    if (member.groupId != null) {
      final groupChat = chats.firstWhere(
        (chat) => chat.type == 'Group' && chat.typeId == member.groupId,
        orElse: () => Chat(remoteId: '', name: '', campRemoteId: '', type: ''),
      );
      if (groupChat.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }
    }

    // Match against room name
    if (member.roomId != null) {
      final roomChat = chats.firstWhere(
        (chat) => chat.type == 'Room' && chat.typeId == member.roomId,
        orElse: () => Chat(remoteId: '', name: '', campRemoteId: '', type: ''),
      );
      if (roomChat.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }
    }

    // Match against role
    if (member.role.toLowerCase().contains(lowerQuery)) {
      return true;
    }

    return false;
  }

  /// Sort members by name (case-insensitive)
  static List<Member> sortByName(List<Member> members) {
    final sorted = List<Member>.from(members);
    sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return sorted;
  }

  /// Sort members by role priority (Owner > Staff > Camper > Others)
  static List<Member> sortByRole(List<Member> members) {
    final sorted = List<Member>.from(members);
    sorted.sort((a, b) {
      final aPriority = _getRolePriority(a.role);
      final bPriority = _getRolePriority(b.role);
      return aPriority.compareTo(bPriority);
    });
    return sorted;
  }

  /// Get role priority for sorting (lower is higher priority)
  static int _getRolePriority(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return 0;
      case 'staff':
        return 1;
      case 'camper':
        return 2;
      case 'pending':
        return 3;
      default:
        return 4;
    }
  }

  /// Group members by role
  static Map<String, List<Member>> groupByRole(List<Member> members) {
    final Map<String, List<Member>> grouped = {};

    for (final member in members) {
      if (!grouped.containsKey(member.role)) {
        grouped[member.role] = [];
      }
      grouped[member.role]!.add(member);
    }

    return grouped;
  }

  /// Get member count by role
  static Map<String, int> getCountByRole(List<Member> members) {
    final Map<String, int> counts = {};

    for (final member in members) {
      counts[member.role] = (counts[member.role] ?? 0) + 1;
    }

    return counts;
  }
}
