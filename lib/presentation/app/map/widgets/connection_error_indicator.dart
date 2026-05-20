import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/socket/socket_connection_state.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';
import 'package:mastercs_mobile/providers/socket/socket_connection_provider.dart';
import 'package:mastercs_mobile/providers/connection/connectivity_provider.dart';

/// A compact widget that displays connection status warnings.
/// Shows nothing when both internet and socket are connected.
/// Shows "Reconnecting..." or "No connection" based on status.
class ConnectionErrorIndicator extends ConsumerWidget {
  const ConnectionErrorIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final socketState = ref.watch(socketConnectionStateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Determine the connection status
    final isInternetOnline = connectivity.value?.isOnline ?? false;
    final isSocketGood =
        socketState.value != null &&
        (socketState.value == SocketConnectionState.connected ||
            socketState.value == SocketConnectionState.authenticated);

    // Both are good - don't show anything
    if (isInternetOnline && isSocketGood) {
      return const SizedBox.shrink();
    }

    // Determine the message
    final String message = 'No connection';
    final Color backgroundColor = colorScheme.errorContainer;
    final Color textColor = colorScheme.onError;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
