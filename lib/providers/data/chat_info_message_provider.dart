import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/repositories/chat_repository.dart';

final chatInfoMessageProvider = StreamProvider<ChatInfoMessage>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return chatRepository.infoMessageStream;
});
