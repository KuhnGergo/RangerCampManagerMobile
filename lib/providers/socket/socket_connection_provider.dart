import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/socket/socket_service.dart';
import 'package:mastercs_mobile/core/socket/socket_connection_state.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

final socketConnectionStateProvider = StreamProvider<SocketConnectionState>((
  ref,
) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.connectionStateStream;
});

final socketLifecycleProvider = StreamProvider<SocketLifecycleEvent>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.lifecycleStream;
});

final socketRuntimeStateProvider = StreamProvider<SocketRuntimeState>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.runtimeStateStream;
});
