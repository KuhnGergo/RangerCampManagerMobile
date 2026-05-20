import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/socket/chat_models.dart';
import 'package:mastercs_mobile/models/socket/group_models.dart';
import 'package:mastercs_mobile/models/socket/location_models.dart';
import 'package:mastercs_mobile/models/socket/message_models.dart';
import 'package:mastercs_mobile/models/socket/socket_connection_models.dart';
import 'package:mastercs_mobile/models/socket/socket_error.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

final socketAuthenticatedProvider = StreamProvider<AuthenticatedData>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.authenticatedStream;
});

final socketUserConnectedProvider = StreamProvider<UserConnectionUpdate>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.userConnectedStream;
});

final socketUserDisconnectedProvider = StreamProvider<UserConnectionUpdate>((
  ref,
) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.userDisconnectedStream;
});

final socketChatViewedProvider = StreamProvider<ChatViewedData>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.chatViewedStream;
});

final socketNewMessageProvider = StreamProvider<NewMessage>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.newMessageStream;
});

final socketMessagesHistoryProvider = StreamProvider<MessageHistoryData>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.messagesHistoryStream;
});

final socketUserTypingProvider = StreamProvider<UserTypingData>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.userTypingStream;
});

final socketUserJoinedGroupProvider = StreamProvider<UserJoinedGroupData>((
  ref,
) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.userJoinedGroupStream;
});

final socketUserLeftGroupProvider = StreamProvider<UserLeftGroupData>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.userLeftGroupStream;
});

final socketLocationUpdatedProvider = StreamProvider<LocationUpdatedData>((
  ref,
) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.locationUpdatedStream;
});

final socketErrorProvider = StreamProvider<SocketError>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.errorStream;
});

final socketGroupEndedProvider = StreamProvider<GroupEndedData>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  return socketService.groupEndedStream;
});
