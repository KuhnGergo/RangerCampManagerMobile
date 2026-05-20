import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/repositories/chat_repository.dart';
import 'package:mastercs_mobile/repositories/message_repository.dart';
import 'package:mastercs_mobile/repositories/member_to_chat_repository.dart';
import 'package:mastercs_mobile/providers/utils/camp_membership_guard.dart';

/// Provider for chat controller - handles chat actions like sending messages
final chatActionsProvider = AsyncNotifierProvider<ChatActionsProvider, void>(
  () => ChatActionsProvider(),
);

/// Controller for chat operations
/// Provides methods to interact with messages and chat functionality
class ChatActionsProvider extends AsyncNotifier<void> {
  late final MessageRepository _messageRepository = ref.read(
    messageRepositoryProvider,
  );
  late final MemberToChatRepository _memberToChatRepository = ref.read(
    memberToChatRepositoryProvider,
  );
  late final ChatRepository _chatRepository = ref.read(chatRepositoryProvider);
  late final AuthProvider _auth = ref.watch(authProvider.notifier);

  @override
  Future<void> build() async {}

  Future<void> refreshChats(String? campId) async {
    state = const AsyncLoading();
    try {
      if (campId == null) {
        throw Exception('Camp ID is null');
      }
      final chats = await _chatRepository.getMyCampChats(campId);
      // Refresh the first page of messages for previews/highlights.
      _messageRepository.getFirstMessagesForAllChats(chats);
      state = const AsyncData(null);
    } catch (e, stack) {
      if (campId != null) {
        await handleCampAccessRevokedIfNeeded(ref, error: e, campId: campId);
      }
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> leaveChat(String campId, String chatId) async {
    state = const AsyncLoading();
    try {
      await _chatRepository.leaveChat(campId, chatId);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> endGroup(Chat groupChat) async {
    state = const AsyncLoading();
    try {
      final userId = _auth.getUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _chatRepository.endGroup(groupChat, userId);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Send a message to a chat
  /// Returns the temporary message ID
  Future<String> sendMessage({
    required String chatId,
    required Map<String, dynamic> body,
    String? replyToMessageId,
  }) async {
    state = const AsyncLoading();
    try {
      final userId = _auth.getUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final messageId = await _messageRepository.sendMessage(
        chatId: chatId,
        body: body,
        replyToMessageId: replyToMessageId,
        currentUserId: userId,
      );

      state = const AsyncData(null);
      return messageId;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Send a text message (convenience method)
  Future<String> sendTextMessage({
    required String chatId,
    required String text,
    String? replyToMessageId,
  }) async {
    final messageId = await sendMessage(
      chatId: chatId,
      body: {'text': text, 'type': 'text'},
      replyToMessageId: replyToMessageId,
    );
    return messageId;
  }

  /// Request message history from server
  void loadMessageHistory({
    required String chatId,
    int limit = 50,
    int offset = 0,
  }) {
    state = const AsyncLoading();
    try {
      _messageRepository.requestMessageHistory(
        chatId: chatId,
        limit: limit,
        offset: offset,
      );
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Mark a chat as viewed by the current user
  /// Emits viewChat socket event to update server and notify other users
  Future<void> viewChat(String chatId) async {
    state = const AsyncLoading();
    try {
      final userId = _auth.getUserId;
      await _memberToChatRepository.viewChat(chatId, currentUserId: userId);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Retry sending unsent messages for a chat
  Future<void> retrySendingUnsentMessages(String chatId) async {
    state = const AsyncLoading();
    try {
      final userId = _auth.getUserId;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _messageRepository.retrySendingUnsentMessages();
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Get unsent message count for a chat (useful for UI indication)
  Future<int> getUnsentMessageCount() async {
    state = const AsyncLoading();
    try {
      final unsentMessages = await _messageRepository.getUnsentMessages();
      state = const AsyncData(null);
      return unsentMessages.length;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}
