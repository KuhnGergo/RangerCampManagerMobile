import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/core/socket/socket_service.dart';
import 'package:mastercs_mobile/data/api/requests/chats_api.dart';
import 'package:mastercs_mobile/data/db/chats_dao.dart';
import 'package:mastercs_mobile/data/db/member_to_camp_dao.dart';
import 'package:mastercs_mobile/data/db/member_to_chat_dao.dart';
import 'package:mastercs_mobile/data/db/messages_dao.dart';
import 'package:mastercs_mobile/models/socket/group_models.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

class ChatInfoMessage {
  final String chatRemoteId;
  final String message;
  final DateTime timestamp;

  const ChatInfoMessage({
    required this.chatRemoteId,
    required this.message,
    required this.timestamp,
  });
}

/// Provider for the ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final api = ref.watch(chatsApiProvider);
  final dao = ref.watch(chatDaoProvider);
  final memberToCampDao = ref.watch(memberToCampDaoProvider);
  final memberToChatDao = ref.watch(memberToChatDaoProvider);
  final messageDao = ref.watch(messagesDaoProvider);
  final socketService = ref.watch(socketServiceProvider);
  final repository = ChatRepository(
    api,
    dao,
    memberToCampDao,
    memberToChatDao,
    messageDao,
    socketService,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Repository that coordinates between ChatsApi and ChatDao
/// Implements business logic for chat operations (rooms, groups, and general chats)
class ChatRepository {
  final ChatsApi _api;
  final ChatDao _chatDao;
  final MemberDao _memberToCampDao;
  final MemberToChatDao _memberToChatDao;
  final MessagesDao _messageDao;
  final SocketService _socketService;

  StreamSubscription<UserJoinedGroupData>? _userJoinedGroupSubscription;
  StreamSubscription<UserLeftGroupData>? _userLeftGroupSubscription;
  StreamSubscription<GroupEndedData>? _groupEndedSubscription;
  final _infoMessageController = StreamController<ChatInfoMessage>.broadcast();

  Stream<ChatInfoMessage> get infoMessageStream =>
      _infoMessageController.stream;

  ChatRepository(
    this._api,
    this._chatDao,
    this._memberToCampDao,
    this._memberToChatDao,
    this._messageDao,
    this._socketService,
  ) {
    _listenToGroupEvents();
  }

  void _listenToGroupEvents() {
    _userJoinedGroupSubscription?.cancel();
    _userLeftGroupSubscription?.cancel();
    _groupEndedSubscription?.cancel();

    _userJoinedGroupSubscription = _socketService.userJoinedGroupStream.listen(
      _handleUserJoinedGroup,
    );
    _userLeftGroupSubscription = _socketService.userLeftGroupStream.listen(
      _handleUserLeftGroup,
    );
    _groupEndedSubscription = _socketService.groupEndedStream.listen(
      _handleGroupEnded,
    );
  }

  /// Update group details
  /// Performs: API call -> update local DB
  /// Don't confuse! roomId and groupId are not the primary keys locally, chatId is!
  Future<void> update({
    required String campId,
    String? groupId,
    String? roomId,
    String? name,
    String? color,
    String? joinCode,
  }) async {
    try {
      if (groupId == null && roomId == null) {
        throw Exception('Group or Room ID must be provided');
      }

      // Call API
      final updatedGroupData = roomId != null
          ? await _api.updateRoom(
              campId: campId,
              roomId: roomId,
              name: name,
              color: color,
              joinCode: joinCode,
            )
          : await _api.updateGroup(
              campId: campId,
              groupId: groupId!,
              name: name,
              color: color,
              joinCode: joinCode,
            );

      // Update chat in local database
      final chat = Chat(
        remoteId: updatedGroupData['chatId'] as String,
        name: updatedGroupData['name'] as String,
        color: updatedGroupData['color'] as String?,
        lastMessageAt: updatedGroupData['lastMessageAt'] != null
            ? DateTime.parse(updatedGroupData['lastMessageAt'] as String)
            : null,
        campRemoteId: campId,
        type: updatedGroupData['type'] as String,
        typeId: groupId != null
            ? updatedGroupData['groupId'] as String?
            : updatedGroupData['roomId'] as String?,
        joinCode: updatedGroupData['joinCode'] as String?,
      );

      await _chatDao.upsertChat(chat);
    } catch (e) {
      rethrow;
    }
  }

  /// Leave a group and remove from local database
  /// Performs: API call -> delete from local DB
  Future<void> leave({
    required Chat chat,
    String type = 'Group',
    String? groupChatId,
    String? roomChatId,
    required String myUserId,
  }) async {
    try {
      // Call API
      final chatDeleted = type == "Room"
          ? await _api.leaveRoom(chat.campRemoteId)
          : await _api.leaveGroup(chat.campRemoteId);

      await leaveLocal(
        chat: chat,
        myUserId: myUserId,
        type: type,
        deleteChat: chatDeleted,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// End a group
  /// Performs: best-effort socket emit, then always leave+delete locally.
  Future<void> endGroup(Chat chat, String myUserId) async {
    final groupId = chat.typeId;

    // Keep UX forward-moving: local deletion should happen even if emit fails.
    if (groupId != null && groupId.isNotEmpty) {
      try {
        _socketService.endGroup(groupId: groupId);
      } catch (_) {
        // Ignore emit failures and continue with local cleanup.
      }
    }

    await leaveLocal(
      chat: chat,
      myUserId: myUserId,
      type: 'Group',
      deleteChat: true,
    );
  }

  Future<void> _handleUserJoinedGroup(UserJoinedGroupData joinedData) async {
    try {
      final groupChat = await _chatDao.getChatByTypeAndTypeId(
        'Group',
        joinedData.groupId,
      );
      if (groupChat == null) {
        return;
      }

      await _memberToChatDao.addUserToChat(
        joinedData.userId,
        groupChat.remoteId,
        null,
      );
    } catch (_) {
      // Best-effort live sync; ignore to keep the stream alive.
    }
  }

  Future<void> _handleUserLeftGroup(UserLeftGroupData leftData) async {
    try {
      final groupChat = await _chatDao.getChatByTypeAndTypeId(
        'Group',
        leftData.groupId,
      );
      if (groupChat == null) {
        return;
      }

      await _memberToChatDao.removeUserFromChat(
        leftData.userId,
        groupChat.remoteId,
      );
    } catch (_) {
      // Best-effort live sync; ignore to keep the stream alive.
    }
  }

  Future<void> _handleGroupEnded(GroupEndedData endedData) async {
    try {
      final groupChat = await _chatDao.getChatByTypeAndTypeId(
        'Group',
        endedData.groupId,
      );
      if (groupChat == null) {
        return;
      }

      await _chatDao.upsertChatCompanion(
        ChatsCompanion(
          remoteId: Value(groupChat.remoteId),
          campRemoteId: Value(groupChat.campRemoteId),
          name: Value(groupChat.name),
          type: const Value('ArchivedGroup'),
          typeId: const Value(null),
          color: Value(groupChat.color),
          joinCode: Value(groupChat.joinCode),
          lastMessageAt: Value(groupChat.lastMessageAt),
          lastSeenAt: Value(groupChat.lastSeenAt),
          createdAt: Value(groupChat.createdAt),
        ),
      );

      final infoMessage = ChatInfoMessage(
        chatRemoteId: groupChat.remoteId,
        message: 'Group ended by ${endedData.endedBy.userName}',
        timestamp: endedData.timestamp,
      );
      if (!_infoMessageController.isClosed) {
        _infoMessageController.add(infoMessage);
      }
    } catch (_) {
      // Best-effort live sync; ignore to keep the stream alive.
    }
  }

  /// Local leave helper (no API call)
  Future<void> leaveLocal({
    required Chat chat,
    required String myUserId,
    String? type = 'Group',
    bool deleteChat = false,
  }) async {
    try {
      // Update member's chat IDs in MemberToCamp table
      if (type == 'Room') {
        await _memberToCampDao.updateMember(
          id: myUserId,
          campId: chat.campRemoteId,
          roomId: null,
        );
      } else if (type == 'Group') {
        await _memberToCampDao.updateMember(
          id: myUserId,
          campId: chat.campRemoteId,
          groupId: null,
        );
      }

      if (deleteChat) {
        // Delete chat and its members from local database
        await _chatDao.deleteChat(chat.remoteId);
        await _memberToChatDao.clearMembersByChatId(chat.remoteId);
        return;
      }

      // Archive chat locally by changing its type
      await _chatDao.upsertChatCompanion(
        ChatsCompanion(
          type: Value(type == 'Group' ? 'ArchivedGroup' : 'ArchivedRoom'),
          typeId: Value(null),
          remoteId: Value(chat.remoteId),
          campRemoteId: Value(chat.campRemoteId),
          name: Value(chat.name),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new group and save to local database
  /// Performs: API call -> save to local DB
  Future<void> create({
    Chat? previousChat,
    required String campId,
    required String name,
    required String color,
    String? joinCode,
    String? type = 'Group',
    String? roomId,
    String? groupId,
    String? myUserId,
  }) async {
    try {
      // Call API
      final chatData = type == 'Room'
          ? await _api.createRoom(
              campId: campId,
              name: name,
              color: color,
              joinCode: joinCode,
            )
          : await _api.createGroup(
              campId: campId,
              name: name,
              color: color,
              joinCode: joinCode,
            );

      // Save chat to local database
      final chat = Chat(
        remoteId: chatData['chatId'] as String,
        name: chatData['name'] as String,
        color: chatData['color'] as String?,
        lastMessageAt: null,
        campRemoteId: campId,
        type: chatData['type'] as String,
        typeId: type == 'Room'
            ? chatData['roomId'] as String?
            : chatData['groupId'] as String?,
        joinCode: chatData['joinCode'] as String?,
        createdAt: chatData['createdAt'] != null
            ? DateTime.parse(chatData['createdAt'] as String)
            : DateTime.now(),
      );

      final member = MemberToChatData(
        chatRemoteId: chat.remoteId,
        userRemoteId: myUserId!,
        lastViewed: null,
      );

      await _chatDao.upsertChat(chat);

      if (type == 'Room') {
        await _memberToCampDao.updateMember(
          id: myUserId,
          campId: campId,
          roomId: chat.typeId,
        );
      } else if (type == 'Group') {
        await _memberToCampDao.updateMember(
          id: myUserId,
          campId: campId,
          groupId: chat.typeId,
        );
      }

      await _memberToChatDao.upsertUsersToChats([chat.remoteId], [member]);

      await localJoin(
        previousChat: previousChat,
        chat: chat,
        type: type,
        roomId: type == 'Room' ? chat.typeId : roomId,
        groupId: type == 'Group' ? chat.typeId : groupId,
        myUserId: myUserId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// join a chat by code and save to local database
  Future<void> join({
    Chat? previousChat,
    required String campId,
    required String code,
    String type = 'Group',
    String? roomId,
    String? groupId,
    String? myUserId,
  }) async {
    try {
      // Call API
      final chatData = type == 'Room'
          ? await _api.joinRoom(campId, code)
          : await _api.joinGroup(campId, code);

      // Save chat to local database
      final chat = Chat(
        remoteId: chatData['chatId'] as String,
        name: chatData['name'] as String,
        color: chatData['color'] as String?,
        lastMessageAt: chatData['lastMessageAt'] != null
            ? DateTime.parse(chatData['lastMessageAt'] as String)
            : null,
        campRemoteId: campId,
        type: chatData['type'] as String,
        typeId: type == 'Room'
            ? chatData['roomId'] as String?
            : chatData['groupId'] as String?,
        joinCode: chatData['joinCode'] as String?,
        createdAt: chatData['createdAt'] != null
            ? DateTime.parse(chatData['createdAt'] as String)
            : DateTime.now(),
      );

      final members = chatData['chatMembers'].map<MemberToChatData>((
        memberData,
      ) {
        return MemberToChatData(
          userRemoteId: memberData['userId'],
          chatRemoteId: chat.remoteId,
          lastViewed: memberData['lastSeen'] != null
              ? DateTime.parse(memberData['lastSeen'])
              : null,
        );
      }).toList();

      await _chatDao.upsertChat(chat);

      await _memberToChatDao.upsertUsersToChats([chat.remoteId], members);

      // Change Room or Group if userId is provided
      if (myUserId == null) {
        return;
      }
      await localJoin(
        previousChat: previousChat,
        chat: chat,
        type: type,
        roomId: type == 'Room' ? chat.typeId : roomId,
        groupId: type == 'Group' ? chat.typeId : groupId,
        myUserId: myUserId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Local join helper (no API call)
  Future<void> localJoin({
    Chat? previousChat,
    required Chat chat,
    String? type = 'Group',
    String? roomId,
    String? groupId,
    required String myUserId,
  }) async {
    try {
      if (previousChat != null) {
        await leaveLocal(
          chat: previousChat,
          myUserId: myUserId,
          type: previousChat.type,
        );
      }
      // Update member's chat IDs in MemberToCamp table
      if (type == 'Room') {
        await _memberToCampDao.updateMember(
          id: myUserId,
          campId: chat.campRemoteId,
          roomId: chat.typeId,
        );
      } else if (type == 'Group') {
        await _memberToCampDao.updateMember(
          id: myUserId,
          campId: chat.campRemoteId,
          groupId: chat.typeId,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Leave a chat and remove from local database
  /// Performs: API call -> delete from local DB
  Future<bool> leaveChat(String campId, String chatId) async {
    try {
      // Call API
      final success = await _api.leaveChat(campId, chatId);

      if (!success) {
        throw Exception('Failed to leave chat');
      }

      final rowsDeleted = await _chatDao.deleteChat(chatId);
      final rowsDeletedMember = await _memberToChatDao.clearMembersByChatId(
        chatId,
      );
      await _messageDao.deleteMessagesByChat(chatId);

      if (rowsDeleted <= 0 || rowsDeletedMember < 0) {
        throw Exception('Failed to delete chat locally');
      }

      return success;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all chats for a specific camp from API and save to local database
  Future<List<Chat>> getMyCampChats(String campId) async {
    try {
      final chatsData = await _api.getMyCampChats(campId);

      final chats = chatsData.map((chatData) {
        return Chat(
          remoteId: chatData['chatId'] as String,
          name: chatData['name'] as String,
          color: chatData['color'] as String?,
          lastMessageAt: chatData['lastMessageAt'] != null
              ? DateTime.parse(chatData['lastMessageAt'] as String)
              : null,
          lastSeenAt: chatData['lastSeenAt'] != null
              ? DateTime.parse(chatData['lastSeenAt'] as String)
              : null,
          campRemoteId: campId,
          type: chatData['type'] as String,
          typeId: chatData['groupId'] ?? chatData['roomId'] as String?,
          joinCode: chatData['joinCode'] as String?,
          createdAt: chatData['createdAt'] != null
              ? DateTime.parse(chatData['createdAt'] as String)
              : DateTime.now(),
        );
      }).toList();

      final membersByChats = chatsData.expand((chat) {
        final chatId = chat['chatId'] as String;
        final membersData = chat['chatMembers'] as List<dynamic>? ?? [];
        return membersData.map((memberData) {
          return MemberToChatData(
            userRemoteId: memberData['userId'],
            chatRemoteId: chatId,
            lastViewed: memberData['lastSeen'] != null
                ? DateTime.parse(memberData['lastSeen'])
                : null,
          );
        });
      }).toList();

      if (chats.isNotEmpty) {
        await _chatDao.upsertAllChats(chats);
      }

      await _memberToChatDao.upsertUsersToChats(
        chats.map((e) => e.remoteId).toList(),
        membersByChats,
      );

      return chats;
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific chat by ID from local database
  Future<Chat?> getChatById(String chatId) async {
    try {
      return await _chatDao.getChatById(chatId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get member count for a chat
  Future<int> getChatMemberCount(String chatRemoteId) async {
    try {
      return await _memberToChatDao.getChatMemberCount(chatRemoteId);
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all chat data for a camp (cleanup when leaving)
  Future<void> clearCampChatData(String campId) async {
    try {
      await _chatDao.deleteChatsByCamp(campId);
      await _memberToChatDao.clearCampChatData(campId);
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _userJoinedGroupSubscription?.cancel();
    _userLeftGroupSubscription?.cancel();
    _groupEndedSubscription?.cancel();
    _infoMessageController.close();
  }
}
