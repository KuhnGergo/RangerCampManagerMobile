import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/chats_dao.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

/// Provider that streams all chats for the currently selected camp
final chatsListProvider = StreamProvider.autoDispose<List<Chat>>((ref) {
  final campId = ref
      .watch(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  if (campId == null) {
    return Stream.value([]);
  }

  return ref.read(chatDaoProvider).watchChatsByCamp(campId);
});

/// Provider that streams chats filtered by type (Room, Group, General, etc.)
final chatsByTypeProvider = StreamProvider.autoDispose
    .family<List<Chat>, String>((ref, type) {
      final campId = ref
          .watch(selectedCampIdProvider)
          .maybeWhen(data: (id) => id, orElse: () => null);

      if (campId == null) {
        return Stream.value([]);
      }

      return ref.read(chatDaoProvider).watchChatsByType(campId, type);
    });
