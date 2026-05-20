import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/socket/socket_connection_state.dart';
import 'package:mastercs_mobile/providers/connection/connectivity_provider.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';
import 'package:mastercs_mobile/providers/socket/socket_connection_provider.dart';

/// Shows a full-width warning banner when internet or socket is disconnected.
/// Returns a SizedBox.shrink when both are connected.
class ChatsNoConnectionBanner extends ConsumerWidget {
  const ChatsNoConnectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final socketState = ref.watch(socketConnectionStateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final isInternetOnline = connectivity.value?.isOnline ?? false;
    final isSocketGood =
        socketState.value == SocketConnectionState.connected ||
        socketState.value == SocketConnectionState.authenticated;

    if (isInternetOnline && isSocketGood) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'No connection',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
