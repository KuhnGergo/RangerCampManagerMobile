import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/socket/socket_connection_state.dart';
import 'package:mastercs_mobile/models/socket/chat_models.dart';
import 'package:mastercs_mobile/providers/socket/socket_connection_provider.dart';
import 'package:mastercs_mobile/providers/socket/socket_event_providers.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

/// Helper provider to get just the list of currently typing users for a chat
final typingUsersListProvider = Provider.family<List<UserTypingData>, String>((
  ref,
  chatId,
) {
  final typingUsersAsync = ref.watch(typingUsersProvider(chatId));

  return typingUsersAsync.when(
    data: (typingUsers) => typingUsers.values.toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider that tracks typing users for a specific chat
/// Returns a map of userId -> UserTypingData for currently typing users
final typingUsersProvider =
    StreamProvider.family<Map<String, UserTypingData>, String>((ref, chatId) {
      final socketService = ref.watch(socketServiceProvider);

      // Create a stream controller to manage the typing users state
      final controller = StreamController<Map<String, UserTypingData>>();
      final typingUsers = <String, UserTypingData>{};

      // Listen to the userTyping stream and filter by chatId
      final typingSubscription = socketService.userTypingStream.listen((
        current,
      ) {
        // Only process events for this chat
        if (current.chatId != chatId) {
          return;
        }

        if (current.isTyping) {
          // User started typing, add or update
          typingUsers[current.userId] = current;
        } else {
          // User stopped typing, remove
          typingUsers.remove(current.userId);
        }

        // Emit updated map
        if (!controller.isClosed) {
          controller.add(Map<String, UserTypingData>.from(typingUsers));
        }
      });

      // Listen to connection state and clear typing users on disconnect
      ref.listen(socketConnectionStateProvider, (previous, next) {
        next.whenData((state) {
          if (state == SocketConnectionState.disconnected ||
              state == SocketConnectionState.connecting) {
            // Clear all typing users when disconnected
            typingUsers.clear();
            if (!controller.isClosed) {
              controller.add({});
            }
          }
        });
      });

      // Listen to userDisconnected events and remove typing indicators
      ref.listen(socketUserDisconnectedProvider, (previous, next) {
        next.whenData((userUpdate) {
          // Remove the disconnected user from typing users
          if (typingUsers.containsKey(userUpdate.userId)) {
            typingUsers.remove(userUpdate.userId);
            if (!controller.isClosed) {
              controller.add(Map<String, UserTypingData>.from(typingUsers));
            }
          }
        });
      });

      // Clean up when the provider is disposed
      ref.onDispose(() {
        typingSubscription.cancel();
        controller.close();
      });

      return controller.stream;
    });
