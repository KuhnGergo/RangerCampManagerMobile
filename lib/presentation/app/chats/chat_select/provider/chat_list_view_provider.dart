import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_category.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/provider/chat_filter_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_chat_provider.dart';
import 'package:mastercs_mobile/providers/data/staff_chat_provider.dart';
import 'package:mastercs_mobile/providers/data/room_provider.dart';
import 'package:mastercs_mobile/providers/data/group_provider.dart';
import 'package:mastercs_mobile/providers/data/chats_list_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_role_provider.dart';

final chatListViewProvider =
    AsyncNotifierProvider<ChatListViewNotifier, Map<ChatCategory, List<Chat>>>(
      () => ChatListViewNotifier(),
    );

class ChatListViewNotifier
    extends AsyncNotifier<Map<ChatCategory, List<Chat>>> {
  @override
  Future<Map<ChatCategory, List<Chat>>> build() async {
    // Listen to all necessary providers
    final filters = ref.watch(chatFilterProvider);
    final allChatsAsync = ref.watch(chatsListProvider);
    final campChatAsync = ref.watch(campChatProvider);
    final staffChatAsync = ref.watch(staffChatProvider);
    final roomChatAsync = ref.watch(roomProvider);
    final groupChatAsync = ref.watch(groupProvider);
    final userRoleAsync = ref.watch(campRoleProvider);

    // Wait for all chats to be loaded
    final allChats = allChatsAsync.when(
      data: (chats) => chats,
      loading: () => <Chat>[],
      error: (_, __) => <Chat>[],
    );

    final userRole = userRoleAsync.value;
    final isCamper = userRole == Role.camper.toString();
    final isOwnerOrStaff =
        userRole == Role.owner.toString() || userRole == Role.staff.toString();

    final List<Chat> remainingChats = List<Chat>.from(allChats);
    final Map<ChatCategory, List<Chat>> result = {};

    // Always create highlighted category first with required chats based on role
    final List<Chat> highlightedChats = [];

    // Camp chat is always required for everyone
    if (campChatAsync.value != null) {
      highlightedChats.add(campChatAsync.value!);
    } else {
      highlightedChats.add(_createEmptyChat(ChatType.emptyCamp));
    }

    // Staff chat is required for owner/staff
    if (isOwnerOrStaff) {
      if (staffChatAsync.value != null) {
        highlightedChats.add(staffChatAsync.value!);
      } else {
        highlightedChats.add(_createEmptyChat(ChatType.emptyStaff));
      }
    }

    // Room chat is required for campers
    if (isCamper) {
      if (roomChatAsync.value != null) {
        highlightedChats.add(roomChatAsync.value!);
      } else {
        highlightedChats.add(_createEmptyChat(ChatType.emptyRoom));
      }
    }

    // Group chat is required for campers
    if (isCamper) {
      if (groupChatAsync.value != null) {
        highlightedChats.add(groupChatAsync.value!);
      } else {
        highlightedChats.add(_createEmptyChat(ChatType.emptyGroup));
      }
    }

    // Add highlighted chats that exist (not empty) to result
    result[ChatCategory.highlighted] = highlightedChats;

    // Remove highlighted chats from remainingChats to avoid duplication in categories
    final highlightedChatIds = highlightedChats
        .where((chat) => chat.remoteId.isNotEmpty)
        .map((chat) => chat.remoteId)
        .toSet();
    remainingChats.removeWhere((chat) {
      return highlightedChatIds.contains(chat.remoteId);
    });

    // Remove archived chats if showArchived is false
    if (!filters.showArchived) {
      remainingChats.removeWhere((chat) {
        final chatType = ChatType.fromString(chat.type);
        return chatType.isArchived;
      });
    }

    // Keep only one type if filterType is set
    if (filters.filterType != null) {
      remainingChats.removeWhere((chat) {
        final chatType = ChatType.fromString(chat.type);
        return chatType != filters.filterType;
      });
    }

    // Sort remaining chats based on orderBy priority
    remainingChats.sort((a, b) {
      for (final orderSubject in filters.orderBy) {
        int comparison = 0;
        switch (orderSubject) {
          case OrderSubject.lastMessage:
            final aTime = a.lastMessageAt;
            final bTime = b.lastMessageAt;
            if (aTime == null && bTime == null) {
              comparison = 0;
            } else if (aTime == null) {
              comparison = 1;
            } else if (bTime == null) {
              comparison = -1;
            } else {
              comparison = bTime.compareTo(aTime); // DESC
            }
            break;
          case OrderSubject.name:
            comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case OrderSubject.createdAt:
            final aTime = a.createdAt;
            final bTime = b.createdAt;
            if (aTime == null && bTime == null) {
              comparison = 0;
            } else if (aTime == null) {
              comparison = 1;
            } else if (bTime == null) {
              comparison = -1;
            } else {
              comparison = bTime.compareTo(aTime); // DESC
            }
            break;
        }
        if (comparison != 0) return comparison;
      }
      return 0;
    });

    // Group remaining chats by category
    if (filters.groupByType) {
      // Map each chat to its category
      final Map<ChatCategory, List<Chat>> grouped = {};

      for (final chat in remainingChats) {
        final chatType = ChatType.fromString(chat.type);
        final ChatCategory category = chatType.category;

        if (!grouped.containsKey(category)) {
          grouped[category] = [];
        }
        grouped[category]!.add(chat);
      }

      result.addAll(grouped);
    } else {
      // All remaining chats go to "other" category
      if (remainingChats.isNotEmpty) {
        result[ChatCategory.other] = remainingChats;
      }
    }

    return result;
  }

  /// Creates an empty chat placeholder for when a required chat doesn't exist
  Chat _createEmptyChat(ChatType type) {
    return Chat(
      remoteId: '',
      name: '',
      type: type.toString(),
      color: '',
      campRemoteId: '',
      typeId: '',
      joinCode: null,
      createdAt: null,
      lastMessageAt: null,
      lastSeenAt: null,
    );
  }
}
