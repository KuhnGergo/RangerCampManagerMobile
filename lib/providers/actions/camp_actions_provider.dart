import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/app_errors.dart';
import 'package:mastercs_mobile/repositories/camp_repository.dart';
import 'package:mastercs_mobile/repositories/chat_repository.dart';
import 'package:mastercs_mobile/repositories/member_repository.dart';
import 'package:mastercs_mobile/repositories/message_repository.dart';
import 'package:mastercs_mobile/repositories/payment_repository.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/providers/utils/camp_membership_guard.dart';

final campActionsProvider = AsyncNotifierProvider<CampActionsProvider, void>(
  () {
    return CampActionsProvider();
  },
);

class CampActionsProvider extends AsyncNotifier<void> {
  late final CampRepository campRepository = ref.read(campRepositoryProvider);
  late final MemberRepository memberRepository = ref.read(
    memberRepositoryProvider,
  );
  late final PaymentRepository paymentRepository = ref.read(
    paymentRepositoryProvider,
  );
  late final ChatRepository chatRepository = ref.read(chatRepositoryProvider);
  late final MessageRepository messageRepository = ref.read(
    messageRepositoryProvider,
  );

  String? get _selectedCampId => ref
      .read(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  @override
  Future<void> build() async {
    return;
  }

  // Get everything thats camp related: members, payments, etc.
  Future<void> getFullCamp({String? campId}) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    final selectedCampId = campId ?? _selectedCampId;
    Object? error;
    StackTrace? stackTrace;
    if (selectedCampId != null) {
      // Try and catch each repository call separately for features to not fail if one fails and show partial data if possible
      try {
        await campRepository.refreshMyCamp(selectedCampId);
      } catch (e, stack) {
        if (await handleCampAccessRevokedIfNeeded(
          ref,
          error: e,
          campId: selectedCampId,
        )) {
          if (!ref.mounted) return;
          state = AsyncError(e, stack);
          return;
        }
        error = e;
        stackTrace = stack;
      }
      try {
        await memberRepository.refreshCampMembers(selectedCampId);
      } catch (e, stack) {
        if (await handleCampAccessRevokedIfNeeded(
          ref,
          error: e,
          campId: selectedCampId,
        )) {
          if (!ref.mounted) return;
          state = AsyncError(e, stack);
          return;
        }
        error = e;
        stackTrace = stack;
      }
      try {
        await paymentRepository.refreshPayments(selectedCampId);
      } catch (e, stack) {
        error = e;
        stackTrace = stack;
      }
      try {
        final chats = await chatRepository.getMyCampChats(selectedCampId);
        messageRepository.getFirstMessagesForAllChats(chats);
      } catch (e, stack) {
        if (await handleCampAccessRevokedIfNeeded(
          ref,
          error: e,
          campId: selectedCampId,
        )) {
          if (!ref.mounted) return;
          state = AsyncError(e, stack);
          return;
        }
        error = e;
        stackTrace = stack;
      }
    }
    if (error != null) {
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace ?? StackTrace.empty);
      return;
    }
    if (!ref.mounted) return;
    state = const AsyncData(null);
  }

  /// Manually refresh camp data
  Future<void> refreshCamp() async {
    try {
      if (!ref.mounted) return;
      state = const AsyncLoading();
      final campId = _selectedCampId;
      if (campId != null) {
        await campRepository.refreshMyCamp(campId);
      }
      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, stack) {
      final campId = _selectedCampId;
      if (campId != null) {
        await handleCampAccessRevokedIfNeeded(ref, error: e, campId: campId);
      }
      if (!ref.mounted) return;
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> handleCampAccessRevoked({
    required String campId,
    required Object error,
  }) async {
    await handleCampAccessRevokedIfNeeded(ref, error: error, campId: campId);
  }

  /// Refresh current camp data
  Future<void> refreshCamps() async {
    try {
      if (!ref.mounted) return;
      state = const AsyncLoading();
      await campRepository.refreshCamps();
      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Select a different camp
  Future<void> selectCamp(String campId) async {
    try {
      if (await campRepository.pendingCamp(campId)) {
        throw PendingCampJoinRequestError();
      }
      await ref.read(selectedCampIdProvider.notifier).select(campId);

      await getFullCamp(campId: campId);

      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, stack) {
      await handleCampAccessRevokedIfNeeded(ref, error: e, campId: campId);
      if (!ref.mounted) return;
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Select a different camp
  Future<void> deselectCamp() async {
    ref.read(selectedCampIdProvider.notifier).deselect();
    if (!ref.mounted) return;
    state = const AsyncData(null);
  }

  /// Join a camp by code and select it
  Future<void> joinCamp(String code) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();

    try {
      await campRepository.joinCamp(code);

      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Update current camp details
  Future<void> updateCampDetails({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    int? minGroupSize,
    String? joinCode,
  }) async {
    if (ref.read(selectedCampIdProvider).value == null) {
      throw Exception('No camp selected');
    }

    if (!ref.mounted) return;
    state = const AsyncLoading();

    try {
      await campRepository.updateCamp(
        id: ref.read(selectedCampIdProvider).value!,
        name: name,
        startDate: startDate,
        endDate: endDate,
        minGroupSize: minGroupSize,
        joinCode: joinCode,
      );
      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, _) {
      if (!ref.mounted) return;
      state = AsyncError(e, StackTrace.empty);
      rethrow;
    }
  }

  /// Create a new camp and select it
  Future<void> createNewCamp({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    int? minGroupSize,
    String? joinCode,
  }) async {
    state = const AsyncLoading();

    try {
      await campRepository.createCamp(
        name: name,
        startDate: startDate,
        endDate: endDate,
        minGroupSize: minGroupSize,
        joinCode: joinCode,
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Leave the camp
  /// If camp is not the current camp leave from camp list
  Future<void> leaveCamp(String? id) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      id ??= _selectedCampId;

      await campRepository.leaveCamp(id!);
      await deleteLocalCampData(id);

      if (_selectedCampId == id) {
        ref.read(selectedCampIdProvider.notifier).deselect();
        if (!ref.mounted) return;
        state = const AsyncData(null);
      }

      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, _) {
      if (!ref.mounted) return;
      state = AsyncError(e, StackTrace.empty);
      rethrow;
    }
  }

  /// Delete the camp (owner only)
  /// If camp is not the current camp delete from camp list
  Future<void> deleteCamp(String? id) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    try {
      id ??= _selectedCampId;

      await campRepository.deleteCamp(id!);
      await deleteLocalCampData(id);

      if (_selectedCampId == id) {
        ref.read(selectedCampIdProvider.notifier).deselect();
        if (!ref.mounted) return;
        state = const AsyncData(null);
      }

      if (!ref.mounted) return;
      state = const AsyncData(null);
    } catch (e, _) {
      if (!ref.mounted) return;
      state = AsyncError(e, StackTrace.empty);
      rethrow;
    }
  }

  Future<void> deleteLocalCampData(String id) async {
    await memberRepository.deleteMembersOfCamp(id);
    await paymentRepository.deletePaymentsOfCamp(id);
    await chatRepository.clearCampChatData(id);
  }

  /// Logout cleanup
  Future<void> clear() async {
    try {
      ref.read(selectedCampIdProvider.notifier).deselect();
    } catch (e, _) {
      rethrow;
    }
  }
}
