import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/repositories/chat_repository.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/providers/data/room_provider.dart';

final roomActionsProvider = AsyncNotifierProvider<RoomActionsProvider, void>(
  () {
    return RoomActionsProvider();
  },
);

class RoomActionsProvider extends AsyncNotifier<void> {
  late final ChatRepository _chatRepository = ref.read(chatRepositoryProvider);

  @override
  Future<void> build() async {
    return;
  }

  String? get _campId => ref
      .read(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  String? get _userId => ref.read(authProvider.notifier).getUserId;

  /// Create a new room
  Future<void> create({
    required String name,
    required String color,
    String? joinCode,
  }) async {
    final campId = _campId;
    final userId = _userId;

    if (campId == null || userId == null) {
      throw Exception('Camp ID or User ID not available');
    }

    state = const AsyncLoading();

    try {
      await _chatRepository.create(
        previousChat: ref.read(roomProvider).value,
        campId: campId,
        name: name,
        color: color,
        joinCode: joinCode,
        type: 'Room',
        myUserId: userId,
      );

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  /// Join an existing room by code
  Future<void> join({required String code}) async {
    final campId = _campId;
    final userId = _userId;

    if (campId == null || userId == null) {
      throw Exception('Camp ID or User ID not available');
    }

    state = const AsyncLoading();

    try {
      await _chatRepository.join(
        previousChat: ref.read(roomProvider).value,
        campId: campId,
        code: code,
        type: 'Room',
        myUserId: userId,
      );

      // Refresh room provider to get the joined room
      ref.invalidate(roomProvider);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  /// Update room details
  Future<void> updateRoom({
    required String roomId,
    String? name,
    String? color,
    String? joinCode,
  }) async {
    final campId = _campId;

    if (campId == null) {
      throw Exception('Camp ID not available');
    }

    state = const AsyncLoading();

    try {
      await _chatRepository.update(
        campId: campId,
        roomId: roomId,
        name: name,
        color: color,
        joinCode: joinCode,
      );

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  /// Leave the current room
  Future<void> leave() async {
    final campId = _campId;
    final userId = _userId;

    if (campId == null || userId == null) {
      throw Exception('Camp ID or User ID not available');
    }

    state = const AsyncLoading();

    try {
      final roomChat = ref.read(roomProvider).value;

      if (roomChat == null) {
        throw Exception(
          'No room chat to leave. Make sure roomProvider is watched.',
        );
      }

      await _chatRepository.leave(
        chat: roomChat,
        type: 'Room',
        myUserId: userId,
      );

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }
}
