import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../models/socket/chat_models.dart';
import '../../models/socket/group_models.dart';
import '../../models/socket/location_models.dart';
import '../../models/socket/message_models.dart';
import '../../models/socket/socket_connection_models.dart';
import '../../models/socket/socket_error.dart';
import 'socket_connection_state.dart';

enum SocketLifecycleEvent { restarting, ready }

enum SocketRuntimeState { stopped, starting, ready, stopping, error }

class SocketService {
  io.Socket? _socket;
  SocketConnectionState _connectionState = SocketConnectionState.disconnected;
  String? _activeToken;
  bool _hasToken = false;
  bool _isDisposed = false;
  SocketLifecycleEvent? _lastLifecycleEvent;
  SocketRuntimeState _runtimeState = SocketRuntimeState.stopped;
  Completer<void>? _readyCompleter;

  // Optional hook set by SocketManager to request a full reconnect when
  // an emit is attempted while disconnected.
  Future<void> Function()? _requestReconnect;

  // Queue outbound emits while disconnected, then flush once authenticated.
  final List<_PendingEmit> _pendingEmits = [];
  bool _isFlushingPendingEmits = false;

  // Stream controllers for connection state
  final _connectionStateController =
      StreamController<SocketConnectionState>.broadcast();
  final _lifecycleController =
      StreamController<SocketLifecycleEvent>.broadcast();
  final _runtimeStateController =
      StreamController<SocketRuntimeState>.broadcast();

  // Stream controllers for events - LISTEN events (emit from server)
  final _authenticatedController =
      StreamController<AuthenticatedData>.broadcast();
  final _userConnectedController =
      StreamController<UserConnectionUpdate>.broadcast();
  final _userDisconnectedController =
      StreamController<UserConnectionUpdate>.broadcast();
  final _chatViewedController = StreamController<ChatViewedData>.broadcast();
  final _newMessageController = StreamController<NewMessage>.broadcast();
  final _messagesHistoryController =
      StreamController<MessageHistoryData>.broadcast();
  final _userTypingController = StreamController<UserTypingData>.broadcast();
  final _userJoinedGroupController =
      StreamController<UserJoinedGroupData>.broadcast();
  final _userLeftGroupController =
      StreamController<UserLeftGroupData>.broadcast();
  final _locationUpdatedController =
      StreamController<LocationUpdatedData>.broadcast();
  final _errorController = StreamController<SocketError>.broadcast();
  final _groupEndedController = StreamController<GroupEndedData>.broadcast();

  // Getters for streams
  Stream<SocketConnectionState> get connectionStateStream async* {
    // Replay current state for late subscribers so UI/providers do not miss
    // fast transitions (e.g., connecting -> connected -> authenticated).
    yield _connectionState;
    yield* _connectionStateController.stream;
  }

  Stream<SocketLifecycleEvent> get lifecycleStream async* {
    final last = _lastLifecycleEvent;
    if (last != null) {
      yield last;
    }
    yield* _lifecycleController.stream;
  }

  Stream<SocketRuntimeState> get runtimeStateStream async* {
    yield _runtimeState;
    yield* _runtimeStateController.stream;
  }

  Stream<AuthenticatedData> get authenticatedStream =>
      _authenticatedController.stream;
  Stream<UserConnectionUpdate> get userConnectedStream =>
      _userConnectedController.stream;
  Stream<UserConnectionUpdate> get userDisconnectedStream =>
      _userDisconnectedController.stream;
  Stream<ChatViewedData> get chatViewedStream => _chatViewedController.stream;
  Stream<NewMessage> get newMessageStream => _newMessageController.stream;
  Stream<MessageHistoryData> get messagesHistoryStream =>
      _messagesHistoryController.stream;
  Stream<UserTypingData> get userTypingStream => _userTypingController.stream;
  Stream<UserJoinedGroupData> get userJoinedGroupStream =>
      _userJoinedGroupController.stream;
  Stream<UserLeftGroupData> get userLeftGroupStream =>
      _userLeftGroupController.stream;
  Stream<LocationUpdatedData> get locationUpdatedStream =>
      _locationUpdatedController.stream;
  Stream<SocketError> get errorStream => _errorController.stream;
  Stream<GroupEndedData> get groupEndedStream => _groupEndedController.stream;

  // Getter for connection state
  SocketConnectionState get connectionState => _connectionState;
  bool get isConnected =>
      _connectionState == SocketConnectionState.connected ||
      _connectionState == SocketConnectionState.authenticated;
  bool get isAuthenticated =>
      _connectionState == SocketConnectionState.authenticated;
  SocketRuntimeState get runtimeState => _runtimeState;
  bool get canSend =>
      _runtimeState == SocketRuntimeState.ready && isAuthenticated;

  bool get hasToken => _hasToken;

  void setTokenAvailability({required bool hasToken}) {
    _hasToken = hasToken;
    if (!hasToken) {
      _disableSocketReconnection();
    }
  }

  void setReconnectRequest(Future<void> Function()? requestReconnect) {
    _requestReconnect = requestReconnect;
  }

  void markRestarting({String reason = 'unknown'}) {
    _emitLifecycleEvent(SocketLifecycleEvent.restarting, reason: reason);
  }

  void _setRuntimeState(SocketRuntimeState state) {
    if (_isDisposed || _runtimeStateController.isClosed) return;
    if (_runtimeState == state) return;

    _runtimeState = state;
    _runtimeStateController.add(state);
    developer.log(
      'Socket runtime state changed to: $state',
      name: 'SocketService',
    );

    if (state == SocketRuntimeState.starting) {
      _readyCompleter = Completer<void>();
      return;
    }

    if (state == SocketRuntimeState.ready) {
      final completer = _readyCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.complete();
      }
      return;
    }

    if (state == SocketRuntimeState.stopped ||
        state == SocketRuntimeState.error) {
      final completer = _readyCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.completeError(StateError('Socket did not reach ready state'));
      }
    }
  }

  Future<bool> waitUntilReady({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (_isDisposed || !_hasToken) return false;
    if (canSend) return true;

    final completer = _readyCompleter ??= Completer<void>();
    try {
      await completer.future.timeout(timeout);
      return canSend;
    } catch (_) {
      return false;
    }
  }

  void _emitLifecycleEvent(SocketLifecycleEvent event, {String? reason}) {
    if (_isDisposed || _lifecycleController.isClosed) return;
    _lastLifecycleEvent = event;
    _lifecycleController.add(event);
    developer.log(
      reason == null
          ? 'Socket lifecycle event: $event'
          : 'Socket lifecycle event: $event ($reason)',
      name: 'SocketService',
    );
  }

  void _disableSocketReconnection() {
    final socket = _socket;
    if (socket == null) return;

    try {
      socket.io.options?['reconnection'] = false;
      socket.io.options?['reconnectionAttempts'] = 0;
    } catch (_) {
      // Best effort: if manager options are unavailable, we still hard-disconnect.
    }
  }

  void _disposeSocketInstance() {
    final socket = _socket;
    if (socket == null) return;

    try {
      socket.clearListeners();
      socket.disconnect();
      socket.dispose();
    } catch (e) {
      developer.log(
        'Error while disposing socket instance: $e',
        name: 'SocketService',
      );
    } finally {
      _socket = null;
      _updateConnectionState(SocketConnectionState.disconnected);
    }
  }

  void _updateConnectionState(SocketConnectionState newState) {
    if (_isDisposed || _connectionStateController.isClosed) return;

    if (_connectionState != newState) {
      _connectionState = newState;
      _connectionStateController.add(newState);
      developer.log(
        'Socket connection state changed to: $newState',
        name: 'SocketService',
      );
    }
  }

  /// Connect to socket server with authentication token
  Future<void> connect(String token, {bool enableReconnection = true}) async {
    await startSession(token, enableReconnection: enableReconnection);
  }

  Future<void> startSession(
    String token, {
    bool enableReconnection = true,
  }) async {
    if (token.isEmpty) {
      throw Exception('Cannot connect socket: token is empty');
    }

    if (_socket != null && _socket!.connected && _activeToken == token) {
      developer.log('Socket already connected', name: 'SocketService');
      return;
    }

    // Always replace existing socket instance before connecting to ensure
    // no previous auth/session references survive token transitions.
    if (_socket != null) {
      _disposeSocketInstance();
    }

    _isDisposed = false;
    _activeToken = token;
    _hasToken = true;
    _setRuntimeState(SocketRuntimeState.starting);
    _emitLifecycleEvent(
      SocketLifecycleEvent.restarting,
      reason: 'start_session',
    );

    developer.log('Connecting socket... $token', name: 'SocketService');

    _updateConnectionState(SocketConnectionState.connecting);

    try {
      // Keep environment parsing consistent with ApiConfig.fromEnvironment().
      // Otherwise, REST can hit PROD while socket hits DEV (or vice versa),
      // causing UNAUTHORIZED for all chat events.
      final envString = (dotenv.env['ENVIRONMENT'] ?? 'production')
          .toLowerCase();
      final isDev =
          envString == 'local' ||
          envString == 'dev' ||
          envString == 'development';

      final socketUrl = isDev
          ? (dotenv.env['DEV_WS_URL'] ?? '')
          : (dotenv.env['WS_URL'] ?? '');

      developer.log(
        'Connecting to socket at: $socketUrl (env=$envString)',
        name: 'SocketService',
      );

      if (socketUrl.isEmpty) {
        final requiredKey = isDev ? 'DEV_WS_URL' : 'WS_URL';
        throw Exception(
          'No WebSocket URL configured. Please add $requiredKey to .env file',
        );
      }

      _socket = io.io(
        socketUrl,
        (() {
          final builder = io.OptionBuilder()
              .setTransports(['websocket'])
              .enableAutoConnect()
              .setAuth({'token': token});

          if (enableReconnection) {
            builder
              ..enableReconnection()
              ..setReconnectionAttempts(5)
              ..setReconnectionDelay(1000)
              ..setReconnectionDelayMax(5000);
          } else {
            builder.disableReconnection();
          }

          final options = builder.build();

          // Prevent socket_io_client internal manager/socket reuse between
          // auth sessions (same URL), which can leak stale authentication.
          options['forceNew'] = true;
          options['multiplex'] = false;

          return options;
        })(),
      );

      _setupEventListeners();

      _socket!.connect();
    } catch (e) {
      developer.log('Error connecting to socket: $e', name: 'SocketService');
      _updateConnectionState(SocketConnectionState.error);
      _setRuntimeState(SocketRuntimeState.error);
      rethrow;
    }
  }

  Future<void> stopSession({
    bool clearPendingEmits = true,
    bool forLogout = false,
  }) async {
    if (forLogout) {
      _hasToken = false;
      _activeToken = null;
      _requestReconnect = null;
      _disableSocketReconnection();
    }

    _setRuntimeState(SocketRuntimeState.stopping);
    disconnect(clearPendingEmits: clearPendingEmits);
    _setRuntimeState(SocketRuntimeState.stopped);
  }

  Future<void> restartSession(String token) async {
    _emitLifecycleEvent(
      SocketLifecycleEvent.restarting,
      reason: 'restart_session',
    );
    await stopSession(clearPendingEmits: false, forLogout: false);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await startSession(token, enableReconnection: true);
  }

  void _setupEventListeners() {
    final socket = _socket;
    if (socket == null) return;

    bool isActiveSocket() => !_isDisposed && identical(_socket, socket);

    // Connection events
    socket.onConnect((_) {
      if (!isActiveSocket()) return;
      developer.log('Socket connected', name: 'SocketService');
      _updateConnectionState(SocketConnectionState.connected);
    });

    socket.onDisconnect((_) {
      if (!isActiveSocket()) return;
      developer.log('Socket disconnected', name: 'SocketService');
      _updateConnectionState(SocketConnectionState.disconnected);
    });

    socket.onConnectError((error) {
      if (!isActiveSocket()) return;
      developer.log('Socket connection error: $error', name: 'SocketService');
      _updateConnectionState(SocketConnectionState.error);
      _setRuntimeState(SocketRuntimeState.error);
    });

    socket.onError((error) {
      if (!isActiveSocket()) return;
      developer.log('Socket error: $error', name: 'SocketService');
    });

    // Server events - LISTEN to these (server emits, we receive)

    // Authentication
    socket.on('authenticated', (data) {
      if (!isActiveSocket()) return;
      _updateConnectionState(SocketConnectionState.authenticated);
      _setRuntimeState(SocketRuntimeState.ready);
      _emitLifecycleEvent(SocketLifecycleEvent.ready);
      _flushPendingEmits();
      try {
        final authenticatedData = AuthenticatedData.fromJson(
          data as Map<String, dynamic>,
        );
        if (!_isDisposed && !_authenticatedController.isClosed) {
          _authenticatedController.add(authenticatedData);
        }
      } catch (e) {
        developer.log(
          'Error parsing authenticated data: $e',
          name: 'SocketService',
        );
      }
    });

    // User connection events
    socket.on('userConnected', (data) {
      if (!isActiveSocket()) return;
      developer.log('User connected: $data', name: 'SocketService');
      try {
        final userUpdate = UserConnectionUpdate.fromJson(
          data as Map<String, dynamic>,
        );
        if (!_isDisposed && !_userConnectedController.isClosed) {
          _userConnectedController.add(userUpdate);
        }
      } catch (e) {
        developer.log(
          'Error parsing userConnected data: $e',
          name: 'SocketService',
        );
      }
    });

    socket.on('userDisconnected', (data) {
      if (!isActiveSocket()) return;
      developer.log('User disconnected: $data', name: 'SocketService');
      try {
        final userUpdate = UserConnectionUpdate.fromJson(
          data as Map<String, dynamic>,
        );
        if (!_isDisposed && !_userDisconnectedController.isClosed) {
          _userDisconnectedController.add(userUpdate);
        }
      } catch (e) {
        developer.log(
          'Error parsing userDisconnected data: $e',
          name: 'SocketService',
        );
      }
    });

    // Chat events
    socket.on('chatViewed', (data) {
      if (!isActiveSocket()) return;
      developer.log('Chat viewed: $data', name: 'SocketService');
      try {
        final chatViewed = ChatViewedData.fromJson(
          data as Map<String, dynamic>,
        );
        if (!_isDisposed && !_chatViewedController.isClosed) {
          _chatViewedController.add(chatViewed);
        }
      } catch (e) {
        developer.log(
          'Error parsing chatViewed data: $e',
          name: 'SocketService',
        );
      }
    });

    // Message events
    socket.on('newMessage', (data) {
      if (!isActiveSocket()) return;
      developer.log('New message: $data', name: 'SocketService');
      try {
        final message = NewMessage.fromJson(data as Map<String, dynamic>);
        if (!_isDisposed && !_newMessageController.isClosed) {
          _newMessageController.add(message);
        }
      } catch (e) {
        developer.log(
          'Error parsing newMessage data: $e',
          name: 'SocketService',
        );
      }
    });

    socket.on('messagesHistory', (data) {
      if (!isActiveSocket()) return;
      developer.log('Messages history received', name: 'SocketService');
      try {
        final history = MessageHistoryData.fromJson(
          data as Map<String, dynamic>,
        );
        if (!_isDisposed && !_messagesHistoryController.isClosed) {
          _messagesHistoryController.add(history);
        }
      } catch (e) {
        developer.log(
          'Error parsing messagesHistory data: $e',
          name: 'SocketService',
        );
      }
    });

    // Typing indicator
    socket.on('userTyping', (data) {
      if (!isActiveSocket()) return;
      try {
        final typing = UserTypingData.fromJson(data as Map<String, dynamic>);
        if (!_isDisposed && !_userTypingController.isClosed) {
          _userTypingController.add(typing);
        }
      } catch (e) {
        developer.log(
          'Error parsing userTyping data: $e',
          name: 'SocketService',
        );
      }
    });

    // Group events
    socket.on('userJoinedGroup', (data) {
      if (!isActiveSocket()) return;
      developer.log('User joined group: $data', name: 'SocketService');
      try {
        final joined = UserJoinedGroupData.fromJson(
          data as Map<String, dynamic>,
        );
        if (!_isDisposed && !_userJoinedGroupController.isClosed) {
          _userJoinedGroupController.add(joined);
        }
      } catch (e) {
        developer.log(
          'Error parsing userJoinedGroup data: $e',
          name: 'SocketService',
        );
      }
    });

    socket.on('userLeftGroup', (data) {
      if (!isActiveSocket()) return;
      developer.log('User left group: $data', name: 'SocketService');
      try {
        final left = UserLeftGroupData.fromJson(data as Map<String, dynamic>);
        if (!_isDisposed && !_userLeftGroupController.isClosed) {
          _userLeftGroupController.add(left);
        }
      } catch (e) {
        developer.log(
          'Error parsing userLeftGroup data: $e',
          name: 'SocketService',
        );
      }
    });

    socket.on('groupEnded', (data) {
      if (!isActiveSocket()) return;
      developer.log('Group ended: $data', name: 'SocketService');
      try {
        final ended = GroupEndedData.fromJson(data as Map<String, dynamic>);
        if (!_isDisposed && !_groupEndedController.isClosed) {
          _groupEndedController.add(ended);
        }
      } catch (e) {
        developer.log(
          'Error parsing groupEnded data: $e',
          name: 'SocketService',
        );
      }
    });

    // Location events
    socket.on('locationUpdated', (data) {
      if (!isActiveSocket()) return;
      try {
        final location = LocationUpdatedData.fromJson(
          data as Map<String, dynamic>,
        );
        if (!_isDisposed && !_locationUpdatedController.isClosed) {
          _locationUpdatedController.add(location);
        }
      } catch (e) {
        developer.log(
          'Error parsing locationUpdated data: $e',
          name: 'SocketService',
        );
      }
    });

    // Error events
    socket.on('error', (data) {
      if (!isActiveSocket()) return;
      developer.log('Socket error event: $data', name: 'SocketService');
      try {
        final error = SocketError.fromJson(data as Map<String, dynamic>);
        if (!_isDisposed && !_errorController.isClosed) {
          _errorController.add(error);
        }
      } catch (e) {
        developer.log('Error parsing error data: $e', name: 'SocketService');
      }
    });
  }

  Future<void> _flushPendingEmits() async {
    if (_isFlushingPendingEmits) return;
    // Only flush once the server confirmed we're authenticated.
    // Some events (e.g., getMessages) may be ignored if emitted before auth.
    if (!isAuthenticated) return;

    _isFlushingPendingEmits = true;
    try {
      while (_pendingEmits.isNotEmpty && isAuthenticated) {
        final next = _pendingEmits.removeAt(0);
        _socket?.emit(next.event, next.data);
        developer.log(
          'Flushed pending emit: ${next.event}',
          name: 'SocketService',
        );
      }
    } finally {
      _isFlushingPendingEmits = false;
    }
  }

  void _emitOrQueue(String event, dynamic data, {required bool dropIfOffline}) {
    final isTransportConnected = _socket != null && _socket!.connected;
    if (isTransportConnected && canSend) {
      _socket!.emit(event, data);
      return;
    }

    if (dropIfOffline) {
      developer.log(
        isTransportConnected
            ? 'Dropping emit ($event): Socket not authenticated yet'
            : 'Dropping emit ($event): Socket not connected',
        name: 'SocketService',
      );
      return;
    }

    developer.log(
      isTransportConnected
          ? 'Queueing emit ($event): Socket not authenticated yet'
          : 'Queueing emit ($event): Socket not connected',
      name: 'SocketService',
    );
    _pendingEmits.add(_PendingEmit(event, data));

    // Best-effort request a reconnect only if we are not even transport-connected.
    // If we are connected but not authenticated, the queue will flush on authenticated.
    if (!isTransportConnected && _hasToken) {
      final request = _requestReconnect;
      if (request != null) {
        // Fire and forget; queue will flush on authenticated.
        unawaited(request());
      }
    }
  }

  // EMIT methods - Client emits these to server (server listens)

  /// View a chat (updates lastViewed timestamp)
  void viewChat(String chatId) {
    _emitOrQueue('viewChat', {'chatId': chatId}, dropIfOffline: false);
    developer.log('Emitted viewChat: $chatId', name: 'SocketService');
  }

  /// Send a message to a chat
  void sendMessage({
    required String chatId,
    required Map<String, dynamic> body,
    required String tempId,
    String? replyToMessageId,
  }) {
    final data = {
      'chatId': chatId,
      'body': body,
      'tempId': tempId,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
    };

    _emitOrQueue('sendMessage', data, dropIfOffline: false);
    developer.log('Emitted sendMessage: $data', name: 'SocketService');
  }

  /// Get messages with pagination
  void getMessages({required String chatId, int limit = 50, int offset = 0}) {
    final data = {'chatId': chatId, 'limit': limit, 'offset': offset};

    _emitOrQueue('getMessages', data, dropIfOffline: false);
    developer.log('Emitted getMessages: $data', name: 'SocketService');
  }

  /// Update typing indicator
  void setTyping({required String chatId, required bool isTyping}) {
    _emitOrQueue('typing', {
      'chatId': chatId,
      'isTyping': isTyping,
    }, dropIfOffline: true);
  }

  /// Update user location
  void updateLocation({
    required String campId,
    required String groupId,
    required double latitude,
    required double longitude,
  }) {
    final data = {
      'campId': campId,
      'groupId': groupId,
      'latitude': latitude,
      'longitude': longitude,
    };

    _emitOrQueue('updateLocation', data, dropIfOffline: false);
    developer.log('Emitted updateLocation', name: 'SocketService');
  }

  /// End a group by groupId.
  void endGroup({required String groupId}) {
    _emitOrQueue('endGroup', {'groupId': groupId}, dropIfOffline: false);
    developer.log('Emitted endGroup: $groupId', name: 'SocketService');
  }

  /// Disconnect from socket server
  void disconnect({bool clearPendingEmits = false}) {
    if (_socket != null) {
      developer.log('Disconnecting socket', name: 'SocketService');
      _disposeSocketInstance();
    }

    _setRuntimeState(SocketRuntimeState.stopped);

    if (clearPendingEmits) {
      _pendingEmits.clear();
    }
  }

  void disconnectForNoToken() {
    unawaited(stopSession(clearPendingEmits: true, forLogout: true));
  }

  /// Clean up resources
  void dispose() {
    _isDisposed = true;
    disconnect();
    _connectionStateController.close();
    _lifecycleController.close();
    _runtimeStateController.close();
    _authenticatedController.close();
    _userConnectedController.close();
    _userDisconnectedController.close();
    _chatViewedController.close();
    _newMessageController.close();
    _messagesHistoryController.close();
    _userTypingController.close();
    _userJoinedGroupController.close();
    _userLeftGroupController.close();
    _locationUpdatedController.close();
    _errorController.close();
    _groupEndedController.close();
  }
}

class _PendingEmit {
  final String event;
  final dynamic data;

  const _PendingEmit(this.event, this.data);
}
