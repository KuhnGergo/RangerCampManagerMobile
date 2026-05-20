import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mastercs_mobile/core/socket/socket_connection_state.dart';
import 'package:mastercs_mobile/providers/socket/socket_connection_provider.dart';
import 'package:mastercs_mobile/providers/socket/socket_event_providers.dart';
import 'package:mastercs_mobile/providers/socket/socket_manager.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

/// Example widget showing how to use socket service and monitor connection state
class SocketConnectionIndicator extends ConsumerWidget {
  const SocketConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(socketConnectionStateProvider);

    return connectionState.when(
      data: (state) {
        final color = _getColorForState(state);
        final icon = _getIconForState(state);
        final label = _getLabelForState(state);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.error, size: 16, color: Colors.red),
    );
  }

  Color _getColorForState(SocketConnectionState state) {
    switch (state) {
      case SocketConnectionState.disconnected:
        return Colors.grey;
      case SocketConnectionState.connecting:
        return Colors.orange;
      case SocketConnectionState.connected:
        return Colors.blue;
      case SocketConnectionState.authenticated:
        return Colors.green;
      case SocketConnectionState.error:
        return Colors.red;
    }
  }

  IconData _getIconForState(SocketConnectionState state) {
    switch (state) {
      case SocketConnectionState.disconnected:
        return Icons.cloud_off;
      case SocketConnectionState.connecting:
        return Icons.cloud_sync;
      case SocketConnectionState.connected:
        return Icons.cloud_queue;
      case SocketConnectionState.authenticated:
        return Icons.cloud_done;
      case SocketConnectionState.error:
        return Icons.error_outline;
    }
  }

  String _getLabelForState(SocketConnectionState state) {
    switch (state) {
      case SocketConnectionState.disconnected:
        return 'Offline';
      case SocketConnectionState.connecting:
        return 'Connecting...';
      case SocketConnectionState.connected:
        return 'Connected';
      case SocketConnectionState.authenticated:
        return 'Online';
      case SocketConnectionState.error:
        return 'Error';
    }
  }
}

/// Example of how to listen to socket events in your widgets
class SocketEventListenerExample extends ConsumerStatefulWidget {
  const SocketEventListenerExample({super.key});

  @override
  ConsumerState<SocketEventListenerExample> createState() =>
      _SocketEventListenerExampleState();
}

class _SocketEventListenerExampleState
    extends ConsumerState<SocketEventListenerExample> {
  @override
  Widget build(BuildContext context) {
    // Listen to new messages
    ref.listen(socketNewMessageProvider, (previous, next) {
      next.whenData((message) {
        // Handle new message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New message in chat ${message.chatId}')),
        );
      });
    });

    // Listen to errors
    ref.listen(socketErrorProvider, (previous, next) {
      next.whenData((error) {
        // Handle socket error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Socket error: ${error.message}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    });

    // Listen to user typing
    ref.listen(socketUserTypingProvider, (previous, next) {
      next.whenData((typing) {
        // Update UI to show typing indicator
        debugPrint(
          '${typing.name} is ${typing.isTyping ? 'typing' : 'not typing'}',
        );
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket Example'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SocketConnectionIndicator(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Socket is integrated and ready to use!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final socketService = ref.read(socketServiceProvider);
                // Example: Send a message
                socketService.sendMessage(
                  chatId: 'chat-id',
                  body: {'text': 'Hello from Flutter!'},
                  tempId: DateTime.now().millisecondsSinceEpoch.toString(),
                );
              },
              child: const Text('Send Test Message'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final socketService = ref.read(socketServiceProvider);
                // Example: Get messages
                socketService.getMessages(
                  chatId: 'chat-id',
                  limit: 50,
                  offset: 0,
                );
              },
              child: const Text('Load Messages'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final socketManager = ref.read(socketManagerProvider.notifier);
                // Example: Manually reconnect
                await socketManager.reconnect();
              },
              child: const Text('Reconnect Socket'),
            ),
          ],
        ),
      ),
    );
  }
}
