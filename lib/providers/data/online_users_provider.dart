import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mastercs_mobile/models/online_user.dart';
import 'package:mastercs_mobile/providers/socket/socket_event_providers.dart';

final onlineUsersProvider =
    NotifierProvider<OnlineUsersNotifier, Map<String, OnlineUser>>(() {
      return OnlineUsersNotifier();
    });

/// Provider that maintains a map of online users
/// Listens to socket events: authenticated, userConnected, userDisconnected
class OnlineUsersNotifier extends Notifier<Map<String, OnlineUser>> {
  @override
  Map<String, OnlineUser> build() {
    // Listen to authenticated event to get initial online users list
    ref.listen(socketAuthenticatedProvider, (previous, next) {
      next.whenData((authenticatedData) {
        final Map<String, OnlineUser> newOnlineUsers = {};

        // Process online users from all camps
        for (final campData in authenticatedData.onlineUsers) {
          for (final userStatus in campData.users) {
            newOnlineUsers[userStatus.userId] = OnlineUser(
              userId: userStatus.userId,
              isOnline: userStatus.isOnline,
              lastSeenAt: userStatus.lastSeenAt,
            );
          }
        }

        // Update state with all online users
        state = newOnlineUsers;
      });
    });

    // Listen to userConnected event
    ref.listen(socketUserConnectedProvider, (previous, next) {
      next.whenData((userUpdate) {
        final updatedUsers = Map<String, OnlineUser>.from(state);
        updatedUsers[userUpdate.userId] = OnlineUser(
          userId: userUpdate.userId,
          isOnline: userUpdate.isOnline,
          lastSeenAt: userUpdate.lastSeenAt,
        );
        state = updatedUsers;
      });
    });

    // Listen to userDisconnected event
    ref.listen(socketUserDisconnectedProvider, (previous, next) {
      next.whenData((userUpdate) {
        final updatedUsers = Map<String, OnlineUser>.from(state);
        updatedUsers[userUpdate.userId] = OnlineUser(
          userId: userUpdate.userId,
          isOnline: userUpdate.isOnline,
          lastSeenAt: userUpdate.lastSeenAt,
        );
        state = updatedUsers;
      });
    });

    // Start with empty map
    return {};
  }

  /// Check if a specific user is online
  bool isUserOnline(String userId) {
    final user = state[userId];
    return user?.isOnline ?? false;
  }

  /// Get all online users
  List<OnlineUser> getOnlineUsers() {
    return state.values.where((user) => user.isOnline).toList();
  }

  /// Get count of online users
  int get onlineCount {
    return state.values.where((user) => user.isOnline).length;
  }
}
