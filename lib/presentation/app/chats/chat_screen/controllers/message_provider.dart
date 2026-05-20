import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mastercs_mobile/data/db/messages_dao.dart';
import 'package:mastercs_mobile/models/chat_message.dart';
import 'package:mastercs_mobile/core/socket/socket_connection_state.dart';
import 'package:mastercs_mobile/providers/socket/socket_connection_provider.dart';
import 'package:mastercs_mobile/providers/socket/socket_event_providers.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

final messageProvider = StateNotifierProvider.autoDispose
    .family<MessageNotifier, MessageState, String>((ref, chatId) {
      return MessageNotifier(ref: ref, chatId: chatId);
    });

class MessageNotifier extends StateNotifier<MessageState> {
  static const _initialLoadCount = 15;
  final Ref _ref;
  final String _chatId;

  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  int? _pendingHistoryOffset;

  MessageNotifier({required Ref ref, required String chatId})
    : _ref = ref,
      _chatId = chatId,
      super(
        const MessageState(
          loadedMessageCount: _initialLoadCount,
          noMore: false,
          isLoadingMore: false,
          messages: [],
        ),
      ) {
    if (_chatId.isEmpty) {
      return;
    }

    _ref.onDispose(() {
      _messagesSubscription?.cancel();
      _messagesSubscription = null;
    });

    // Listen for history batches to update hasMore/noMore + loading state.
    _ref.listen(socketMessagesHistoryProvider, (_, next) {
      next.whenData((history) {
        if (history.chatId != _chatId) return;

        if (!history.hasMore) {
          state = state.copyWith(noMore: true);
        }

        // Reset loading once the server responded for our last request.
        final pendingOffset = _pendingHistoryOffset;
        if (pendingOffset != null && history.offset == pendingOffset) {
          _pendingHistoryOffset = null;
          state = state.copyWith(isLoadingMore: false);
        }
      });
    });

    // After a reconnect, only request messages again when socket is
    // authenticated to avoid firing getMessages into an unstable transport.
    _ref.listen(socketConnectionStateProvider, (previous, next) {
      final previousState = previous?.value;
      final nextState = next.value;

      final becameAuthenticated =
          previousState != SocketConnectionState.authenticated &&
          nextState == SocketConnectionState.authenticated;

      if (!becameAuthenticated || _chatId.isEmpty) return;

      _ref
          .read(socketServiceProvider)
          .getMessages(
            chatId: _chatId,
            limit: state.loadedMessageCount,
            offset: 0,
          );
    });

    _subscribeToMessages(limit: state.loadedMessageCount);
  }

  void loadOlder() {
    if (state.noMore || state.isLoadingMore) return;

    final offset = state.loadedMessageCount;
    final nextCount = state.loadedMessageCount + 20;

    _pendingHistoryOffset = offset;

    state = state.copyWith(loadedMessageCount: nextCount, isLoadingMore: true);

    _subscribeToMessages(limit: nextCount);

    _ref
        .read(socketServiceProvider)
        .getMessages(chatId: _chatId, limit: 20, offset: offset);
  }

  void _subscribeToMessages({required int limit}) {
    _messagesSubscription?.cancel();

    final dao = _ref.read(messagesDaoProvider);
    _messagesSubscription = dao
        .watchMessagesByChatPaged(_chatId, limit: limit)
        .map((rows) => rows.map(ChatMessage.fromDriftMessage).toList())
        .listen((messages) {
          state = state.copyWith(messages: messages);
        });
  }
}

class MessageState {
  final List<ChatMessage> messages;
  final int loadedMessageCount;
  final bool noMore;
  final bool isLoadingMore;

  const MessageState({
    this.messages = const [],
    this.loadedMessageCount = 15,
    this.noMore = false,
    this.isLoadingMore = false,
  });

  MessageState copyWith({
    List<ChatMessage>? messages,
    int? loadedMessageCount,
    bool? noMore,
    bool? isLoadingMore,
  }) {
    return MessageState(
      messages: messages ?? this.messages,
      loadedMessageCount: loadedMessageCount ?? this.loadedMessageCount,
      noMore: noMore ?? this.noMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
