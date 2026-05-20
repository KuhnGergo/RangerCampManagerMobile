import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/repositories/member_repository.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

final campMemberActionsProvider =
    AsyncNotifierProvider<CampMemberActionsProvider, void>(() {
      return CampMemberActionsProvider();
    });

class CampMemberActionsProvider extends AsyncNotifier<void> {
  late final MemberRepository memberRepository = ref.read(
    memberRepositoryProvider,
  );

  String? get _selectedCampId => ref
      .read(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  @override
  Future<void> build() async {
    return;
  }

  /// Promote a member from Camper to Staff
  Future<void> promoteMember(Member member) async {
    try {
      state = const AsyncLoading();
      final campId = _selectedCampId;
      if (campId == null) {
        throw Exception('Camp ID or User ID is null');
      }

      final newRole = member.role == 'Camper' ? 'Staff' : 'Staff';
      await memberRepository.updateRole(campId, member.userRemoteId, newRole);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Demote a member from Staff to Camper
  Future<void> demoteMember(Member member) async {
    try {
      state = const AsyncLoading();
      final campId = _selectedCampId;
      if (campId == null) {
        throw Exception('Camp ID or User ID is null');
      }

      await memberRepository.updateRole(campId, member.userRemoteId, 'Camper');

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Accept a pending member (change role from Pending to Camper)
  Future<void> acceptMember(Member member) async {
    try {
      state = const AsyncLoading();
      final campId = _selectedCampId;
      if (campId == null) {
        throw Exception('Camp ID or User ID is null');
      }

      await memberRepository.acceptMember(campId, member.userRemoteId);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Decline/Remove a pending member
  Future<void> declineMember(Member member) async {
    try {
      state = const AsyncLoading();
      final campId = _selectedCampId;
      if (campId == null) {
        throw Exception('Camp ID or User ID is null');
      }

      await memberRepository.removeMember(campId, member.userRemoteId);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  /// Kick/Remove a member from the camp
  Future<void> kickMember(Member member) async {
    try {
      state = const AsyncLoading();
      final campId = _selectedCampId;
      if (campId == null) {
        throw Exception('Camp ID or User ID is null');
      }

      await memberRepository.removeMember(campId, member.userRemoteId);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}
