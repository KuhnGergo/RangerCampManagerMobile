import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/connection/connectivity_provider.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';
import 'package:mastercs_mobile/core/socket/socket_service.dart';
import 'package:mastercs_mobile/core/socket/socket_connection_state.dart';
import 'package:mastercs_mobile/repositories/message_repository.dart';

/// Socket manager that handles connection lifecycle with auth integration
class SocketManager extends Notifier<void> {
  late final SocketService _socketService = ref.read(socketServiceProvider);
  StreamSubscription<SocketConnectionState>? _connectionStateSub;
  Timer? _restartDebounce;

  @override
  void build() {
    // Allow SocketService to request reconnect only when SessionFlow has
    // established a valid token-bound session.
    _socketService.setReconnectRequest(reconnect);

    // If connectivity comes back, fully restart the socket.
    // This helps recover from half-open connections after network switches.
    ref.listen<AsyncValue<InternetStatus>>(connectivityProvider, (
      previous,
      next,
    ) {
      final previousStatus = (previous != null && previous.hasValue)
          ? previous.value
          : null;
      final nextStatus = next.hasValue ? next.value : null;

      final wasOnline = previousStatus != null && previousStatus.isOnline;
      final isOnline = nextStatus != null && nextStatus.isOnline;

      if (!wasOnline && isOnline) {
        _scheduleFullRestart(reason: 'connectivity_reconnected');
      }
    });

    // Listen to socket connection state changes
    _connectionStateSub?.cancel();
    _connectionStateSub = _socketService.connectionStateStream.listen((state) {
      if (state == SocketConnectionState.authenticated) {
        _onSocketAuthenticated();
      }
    });

    // Clean up on dispose
    ref.onDispose(() {
      _socketService.setReconnectRequest(null);
      _connectionStateSub?.cancel();
      _restartDebounce?.cancel();
      _disconnectSocket(clearPendingEmits: true);
    });
  }

  /// Connect socket for current auth token.
  Future<void> connectForActiveToken({required String reason}) async {
    final token = ref.read(authProvider.notifier).getToken;
    final hasToken = token != null;

    _socketService.setTokenAvailability(hasToken: hasToken);

    if (!hasToken) {
      _restartDebounce?.cancel();
      _socketService.setReconnectRequest(null);
      developer.log(
        'No token available, forcing full socket teardown ($reason)',
        name: 'SocketManager',
      );
      _socketService.disconnectForNoToken();
      return;
    }

    _socketService.setReconnectRequest(reconnect);
    await _connectSocket();
    await _socketService.waitUntilReady();
  }

  /// Full teardown used for logout and cross-session reset.
  Future<void> fullDisconnectForLogout({required String reason}) async {
    developer.log(
      'Full socket teardown requested ($reason)',
      name: 'SocketManager',
    );
    _socketService.markRestarting(reason: 'full_disconnect_$reason');
    _restartDebounce?.cancel();
    _socketService.setReconnectRequest(null);
    _socketService.setTokenAvailability(hasToken: false);
    await _socketService.stopSession(clearPendingEmits: true, forLogout: true);
  }

  /// Called when socket reaches authenticated state
  void _onSocketAuthenticated() {
    developer.log(
      'Socket authenticated, retrying unsent messages',
      name: 'SocketManager',
    );

    // Retry sending any messages that failed or weren't sent
    final messageRepository = ref.read(messageRepositoryProvider);
    messageRepository.retrySendingUnsentMessages();
  }

  Future<void> _connectSocket() async {
    final auth = ref.read(authProvider.notifier);
    final token = auth.getToken;

    if (token == null) {
      developer.log(
        'Cannot connect socket: No auth token',
        name: 'SocketManager',
      );
      return;
    }

    if (_socketService.isConnected) {
      developer.log('Socket already connected', name: 'SocketManager');
      return;
    }

    try {
      developer.log('Connecting socket with token', name: 'SocketManager');
      await _socketService.startSession(token, enableReconnection: true);
    } catch (e) {
      developer.log('Failed to connect socket: $e', name: 'SocketManager');
    }
  }

  void _disconnectSocket({bool clearPendingEmits = false}) {
    developer.log('Disconnecting socket', name: 'SocketManager');
    unawaited(
      _socketService.stopSession(
        clearPendingEmits: clearPendingEmits,
        forLogout: false,
      ),
    );
  }

  void _scheduleFullRestart({required String reason}) {
    _restartDebounce?.cancel();
    _restartDebounce = Timer(const Duration(milliseconds: 700), () async {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.hasValue
          ? (authState.value ?? false)
          : false;
      final hasToken = ref.read(authProvider.notifier).getToken != null;

      if (!isAuthenticated || !hasToken) {
        developer.log(
          'Skipping socket restart ($reason): no active token/auth',
          name: 'SocketManager',
        );
        return;
      }

      developer.log(
        'Connectivity restored; fully restarting socket ($reason)',
        name: 'SocketManager',
      );

      await reconnect();
    });
  }

  /// Manually reconnect socket
  Future<void> reconnect() async {
    final hasToken = ref.read(authProvider.notifier).getToken != null;
    if (!hasToken) {
      developer.log('Skipping reconnect: token is null', name: 'SocketManager');
      _socketService.markRestarting(reason: 'reconnect_skipped_no_token');
      _socketService.setReconnectRequest(null);
      await _socketService.stopSession(
        clearPendingEmits: true,
        forLogout: true,
      );
      return;
    }

    _socketService.markRestarting(reason: 'reconnect');
    final token = ref.read(authProvider.notifier).getToken;
    if (token == null) return;

    await _socketService.restartSession(token);
    await _socketService.waitUntilReady();
  }
}

final socketManagerProvider = NotifierProvider<SocketManager, void>(() {
  return SocketManager();
});
