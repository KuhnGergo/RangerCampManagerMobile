import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/repositories/chat_repository.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/providers/data/group_provider.dart';

final groupActionsProvider = AsyncNotifierProvider<GroupActionsProvider, void>(
  () {
    return GroupActionsProvider();
  },
);

class GroupActionsProvider extends AsyncNotifier<void> {
  late final ChatRepository _chatRepository = ref.read(chatRepositoryProvider);

  @override
  Future<void> build() async {
    return;
  }

  String? get _campId => ref
      .read(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  String? get _userId => ref.read(authProvider.notifier).getUserId;

  /// Create a new group
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
        previousChat: ref.read(groupProvider).value,
        campId: campId,
        name: name,
        color: color,
        joinCode: joinCode,
        type: 'Group',
        myUserId: userId,
      );

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  /// Join an existing group by code
  Future<void> join({required String code}) async {
    final campId = _campId;
    final userId = _userId;

    if (campId == null || userId == null) {
      throw Exception('Camp ID or User ID not available');
    }

    state = const AsyncLoading();

    try {
      await _chatRepository.join(
        previousChat: ref.read(groupProvider).value,
        campId: campId,
        code: code,
        type: 'Group',
        myUserId: userId,
      );

      // Refresh group provider to get the joined group
      ref.invalidate(groupProvider);
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  /// Update group details
  Future<void> updateGroup({
    required String groupId,
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
        groupId: groupId,
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

  /// Leave the current group
  Future<void> leave() async {
    final campId = _campId;
    final userId = _userId;

    if (campId == null || userId == null) {
      throw Exception('Camp ID or User ID not available');
    }

    state = const AsyncLoading();

    try {
      final groupChat = ref.read(groupProvider).value;

      if (groupChat == null) {
        throw Exception(
          'No group chat to leave. Make sure groupProvider is watched.',
        );
      }

      await _chatRepository.leave(
        chat: groupChat,
        type: 'Group',
        myUserId: userId,
      );

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  /// End the current group
  Future<void> endGroup() async {
    final campId = _campId;
    final userId = _userId;

    if (campId == null || userId == null) {
      throw Exception('Camp ID or User ID not available');
    }

    state = const AsyncLoading();

    try {
      final groupChat = ref.read(groupProvider).value;

      if (groupChat == null) {
        throw Exception(
          'No group chat to end. Make sure groupProvider is watched.',
        );
      }

      await _chatRepository.endGroup(groupChat, userId);

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }
}
