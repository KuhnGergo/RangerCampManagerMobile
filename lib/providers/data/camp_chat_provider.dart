import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/chats_dao.dart';
import 'package:mastercs_mobile/providers/data/camp_provider.dart';

/// Provider for watching the camp chat in the selected camp
final campChatProvider = StreamProvider.autoDispose<Chat?>((ref) async* {
  final campAsync = ref.watch(campProvider);

  final camp = campAsync.value;
  if (camp == null || camp.chatRemoteId == null || camp.chatRemoteId!.isEmpty) {
    yield null;
    return;
  }

  // Watch the camp chat
  final chatStream = ref
      .watch(chatDaoProvider)
      .watchChatById(camp.chatRemoteId!);

  await for (final chat in chatStream) {
    yield chat;
  }
});
