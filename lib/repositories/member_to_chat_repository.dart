import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/socket/socket_service.dart';
import 'package:mastercs_mobile/data/db/chats_dao.dart';
import 'package:mastercs_mobile/data/db/member_to_chat_dao.dart';
import 'package:mastercs_mobile/models/socket/chat_models.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

/// Provider for the MemberToChatRepository
final memberToChatRepositoryProvider = Provider<MemberToChatRepository>((ref) {
  final memberToChatDao = ref.watch(memberToChatDaoProvider);
  final chatDao = ref.watch(chatDaoProvider);
  final socketService = ref.watch(socketServiceProvider);
  final repository = MemberToChatRepository(
    memberToChatDao,
    chatDao,
    socketService,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// Repository that handles member-to-chat operations
/// Listens to chatViewed socket events and updates lastViewed timestamps
class MemberToChatRepository {
  final MemberToChatDao _memberToChatDao;
  final ChatDao _chatDao;
  final SocketService _socketService;
  StreamSubscription<ChatViewedData>? _chatViewedSubscription;

  MemberToChatRepository(
    this._memberToChatDao,
    this._chatDao,
    this._socketService,
  ) {
    _listenToChatViewed();
  }

  /// Start listening to chatViewed socket events
  void _listenToChatViewed() {
    _chatViewedSubscription?.cancel();

    _chatViewedSubscription = _socketService.chatViewedStream.listen((
      chatViewedData,
    ) async {
      await _handleChatViewed(chatViewedData);
    });
  }

  /// Handle incoming chatViewed event from socket
  /// Updates the lastViewed timestamp for the user in the chat
  Future<void> _handleChatViewed(ChatViewedData chatViewedData) async {
    try {
      await _memberToChatDao.upsertMemberChatLastViewed(
        chatViewedData.userId,
        chatViewedData.chatId,
        chatViewedData.viewedAt,
      );
    } catch (e) {
      // Log error but don't throw to prevent stream from breaking
      dev.log('Error handling chat viewed event: $e');
    }
  }

  /// Mark a chat as viewed by emitting viewChat socket event
  Future<void> viewChat(String chatId, {String? currentUserId}) async {
    if (currentUserId != null && currentUserId.isNotEmpty) {
      // Local-first write for current user unread state lives in chats.lastSeenAt.
      await _chatDao.updateChatLastSeenAt(chatId, DateTime.now());
    }
    _socketService.viewChat(chatId);
  }

  /// Clean up resources
  void dispose() {
    _chatViewedSubscription?.cancel();
  }
}
