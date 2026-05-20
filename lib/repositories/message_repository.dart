import 'dart:async';
import 'dart:developer' as dev;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/core/schema/tables/messages_table.dart';
import 'package:mastercs_mobile/core/socket/socket_service.dart';
import 'package:mastercs_mobile/data/db/messages_dao.dart';
import 'package:mastercs_mobile/models/socket/message_models.dart';
import 'package:mastercs_mobile/models/socket/socket_error.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';
import 'package:uuid/uuid.dart';

/// Provider for the MessageRepository
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final dao = ref.watch(messagesDaoProvider);
  final socketService = ref.watch(socketServiceProvider);
  return MessageRepository(dao, socketService);
});

/// Repository that handles message operations with optimistic updates
/// and socket synchronization
class MessageRepository {
  final MessagesDao _dao;
  final SocketService _socketService;
  StreamSubscription<NewMessage>? _newMessageSubscription;
  StreamSubscription<SocketError>? _errorSubscription;

  MessageRepository(this._dao, this._socketService) {
    _listenToNewMessages();
    _listenToMessagesHistory();
    _listenToSocketErrors();
  }

  /// Start listening to newMessage socket events and upsert to database
  void _listenToNewMessages() {
    _newMessageSubscription?.cancel();

    // Listen to the stream provider
    _socketService.newMessageStream.listen((newMessage) async {
      await _handleNewMessage(newMessage);
    });
  }

  /// Start listening to messagesHistory socket events and batch upsert to database
  void _listenToMessagesHistory() {
    // Listen to the stream provider
    _socketService.messagesHistoryStream.listen((historyData) async {
      await _handleMessagesHistory(historyData);
    });
  }

  /// Start listening to socket error events
  void _listenToSocketErrors() {
    _errorSubscription?.cancel();

    _socketService.errorStream.listen((socketError) async {
      await _handleSocketError(socketError);
    });
  }

  /// Handle socket errors - mark messages as error status
  Future<void> _handleSocketError(SocketError socketError) async {
    try {
      // For now, we'll mark all currently sending messages as error
      // In a more sophisticated implementation, you could track which
      // tempId corresponds to which error
      dev.log('Socket error: ${socketError.code} - ${socketError.message}');

      // Get all messages currently in sending status
      final sendingMessages = await _dao.getMessagesNeedingRetry();

      for (final message in sendingMessages) {
        if (message.messageStatus == MessageStatus.sending) {
          await _dao.updateMessageStatus(message.id, MessageStatus.error);
        }
      }
    } catch (e) {
      dev.log('Error handling socket error: $e');
    }
  }

  /// Handle incoming newMessage event from socket
  Future<void> _handleNewMessage(NewMessage newMessage) async {
    try {
      // Check if this is a message we sent (update optimistic message)
      Message? existingMessage;
      if (newMessage.tempId != null) {
        existingMessage = await _dao.getMessageByTempId(newMessage.tempId!);
      }

      if (existingMessage != null && newMessage.tempId != null) {
        // Update our optimistic message with server data
        await _dao.upsertMessageByRemoteId(
          newMessage.tempId!,
          newMessage.id,
          newMessage.createdAt,
        );
      } else {
        // This is a new message from another user, insert it
        final message = Message(
          id:
              newMessage.tempId ??
              newMessage.id, // Use tempId or remoteId as local ID
          remoteId: newMessage.id,
          chatRemoteId: newMessage.chatId,
          userRemoteId: newMessage.userId,
          bodyJson: _dao.bodyToJson(newMessage.body),
          createdAt: newMessage.createdAt,
          isSynced: true,
          messageStatus: MessageStatus.arrived,
        );

        await _dao.upsertMessage(message);
      }
    } catch (e) {
      // Log error but don't throw to prevent stream from breaking
      dev.log('Error handling new message: $e');
    }
  }

  /// Handle incoming messagesHistory event from socket
  /// Batch upserts all messages from history
  Future<void> _handleMessagesHistory(MessageHistoryData historyData) async {
    try {
      // Convert NewMessage list to Message list and batch upsert
      for (final newMessage in historyData.messages) {
        // Check if this is an optimistic message we already have
        Message? existingMessage;
        if (newMessage.tempId != null) {
          existingMessage = await _dao.getMessageByTempId(newMessage.tempId!);
        }

        if (existingMessage != null && newMessage.tempId != null) {
          // Update optimistic message with server data
          await _dao.upsertMessageByRemoteId(
            newMessage.tempId!,
            newMessage.id,
            newMessage.createdAt,
          );
        } else {
          // Check if we already have this message by remoteId to avoid duplicates
          final existingByRemoteId = await _dao.getMessageByRemoteId(
            newMessage.id,
          );

          if (existingByRemoteId == null) {
            // Insert new message from history
            final message = Message(
              id:
                  newMessage.tempId ??
                  newMessage.id, // Use tempId or remoteId as local ID
              remoteId: newMessage.id,
              chatRemoteId: newMessage.chatId,
              userRemoteId: newMessage.userId,
              bodyJson: _dao.bodyToJson(newMessage.body),
              createdAt: newMessage.createdAt,
              isSynced: true,
              messageStatus: MessageStatus.arrived,
            );

            await _dao.upsertMessage(message);
          } else {
            // Keep existing local ID, but refresh server-backed fields.
            final updatedMessage = Message(
              id: existingByRemoteId.id,
              remoteId: newMessage.id,
              chatRemoteId: newMessage.chatId,
              userRemoteId: newMessage.userId,
              bodyJson: _dao.bodyToJson(newMessage.body),
              createdAt: newMessage.createdAt,
              isSynced: true,
              messageStatus: MessageStatus.arrived,
            );

            await _dao.upsertMessage(updatedMessage);
          }
        }
      }
    } catch (e, stackTrace) {
      // Log error but don't throw to prevent stream from breaking
      dev.log(
        'Error handling messages history: $e',
        name: 'MessageRepository',
        stackTrace: stackTrace,
      );
    }
  }

  /// Send a message with optimistic update
  /// 1. Generate tempId and save to database immediately
  /// 2. Emit message through socket
  /// 3. Wait for newMessage event to update with server data
  Future<String> sendMessage({
    required String chatId,
    required Map<String, dynamic> body,
    String? replyToMessageId,
    required String currentUserId,
  }) async {
    // Generate temporary ID for optimistic update
    const uuid = Uuid();
    final tempId = uuid.v4();

    try {
      // 1. Optimistically save to database
      final optimisticMessage = MessagesCompanion(
        id: Value(tempId),
        remoteId: const Value(null), // Will be set when server responds
        chatRemoteId: Value(chatId),
        userRemoteId: Value(currentUserId),
        bodyJson: Value(_dao.bodyToJson(body)),
        createdAt: Value(DateTime.now()),
        isSynced: const Value(false), // Mark as not synced yet
        messageStatus: const Value(MessageStatus.sending), // Mark as sending
      );

      await _dao.insertMessage(optimisticMessage);

      // 2. Emit message through socket
      _socketService.sendMessage(
        chatId: chatId,
        body: body,
        tempId: tempId,
        replyToMessageId: replyToMessageId,
      );

      // Return tempId so caller can track this message
      return tempId;
    } catch (e) {
      // If optimistic save fails, don't send through socket
      rethrow;
    }
  }

  /// Get messages for a chat
  Future<List<Message>> getMessagesByChat(String chatId) {
    return _dao.getMessagesByChat(chatId);
  }

  void getFirstMessagesForAllChats(List<Chat> chatIds) {
    for (final chat in chatIds) {
      if (chat.remoteId.isEmpty) continue;
      _socketService.getMessages(chatId: chat.remoteId, limit: 10, offset: 0);
    }
  }

  /// Request message history from server via socket
  void requestMessageHistory({
    required String chatId,
    int limit = 50,
    int offset = 0,
  }) {
    _socketService.getMessages(chatId: chatId, limit: limit, offset: offset);
  }

  /// Get unsent messages (for retry logic)
  Future<List<Message>> getUnsentMessages() {
    return _dao.getUnsentMessages();
  }

  /// Retry sending unsent messages (messages with sending or error status)
  Future<void> retrySendingUnsentMessages() async {
    final messagesNeedingRetry = await _dao.getMessagesNeedingRetry();

    for (final message in messagesNeedingRetry) {
      try {
        // Update status to sending before retrying
        await _dao.updateMessageStatus(message.id, MessageStatus.sending);

        final body = _dao.parseBodyJson(message.bodyJson);

        _socketService.sendMessage(
          chatId: message.chatRemoteId,
          body: body,
          tempId: message.id,
        );
      } catch (e) {
        dev.log('Error retrying message ${message.id}: $e');
        // Mark as error if retry fails
        await _dao.updateMessageStatus(message.id, MessageStatus.error);
      }
    }
  }

  /// Delete messages from a chat (e.g. for moderators)
  Future<void> deleteMessages({
    required String chatId,
    required List<String> messageIds,
  }) async {
    try {
      await _dao.deleteMessages(messageIds);
    } catch (e) {
      rethrow;
    }
  }

  /// Clean up resources
  void dispose() {
    _newMessageSubscription?.cancel();
    _errorSubscription?.cancel();
  }
}
