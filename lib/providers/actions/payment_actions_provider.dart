import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/repositories/member_repository.dart';
import 'package:mastercs_mobile/repositories/payment_repository.dart';

final paymentActionsProvider =
    AsyncNotifierProvider<PaymentActionsNotifier, void>(() {
      return PaymentActionsNotifier();
    });

class PaymentActionsNotifier extends AsyncNotifier<void> {
  late final PaymentRepository _repository;
  late final MemberRepository _memberRepository;

  @override
  Future<void> build() async {
    _repository = ref.read(paymentRepositoryProvider);
    _memberRepository = ref.read(memberRepositoryProvider);
  }

  String? get _campId => ref
      .read(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  String? get _userId => ref.read(authProvider.notifier).getUserId;

  Future<void> refreshPayments() async {
    try {
      state = const AsyncValue.loading();
      final campId = ref.read(selectedCampIdProvider).value;
      if (campId == null) {
        throw Exception('Camp ID not available');
      }
      await _repository.refreshPayments(campId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> refreshWithUserPayments() async {
    try {
      state = const AsyncValue.loading();
      final campId = ref.read(selectedCampIdProvider).value;
      if (campId == null) {
        throw Exception('Camp ID not available');
      }
      await _repository.refreshPayments(campId);
      await _memberRepository.refreshCampMembers(campId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> _refreshUserPayments() async {
    try {
      if (!ref.mounted) return;
      state = const AsyncValue.loading();
      final campId = ref.read(selectedCampIdProvider).value;
      if (campId == null) {
        throw Exception('Camp ID not available');
      }
      await _memberRepository.refreshCampMembers(campId);
      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Add a new payment to the current camp
  Future<void> addPayment({
    required String name,
    required int amount,
    required String currency,
    DateTime? dueDate,
  }) async {
    final campId = _campId;
    final userId = _userId;

    if (campId == null || userId == null) {
      throw Exception('Camp ID or User ID not available');
    }

    if (!ref.mounted) return;
    state = const AsyncValue.loading();

    try {
      await _repository.addPayment(
        campId: campId,
        name: name,
        amount: amount,
        currency: currency,
        dueDate: dueDate,
      );
      await _refreshUserPayments();

      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Remove a payment from the database
  Future<void> removePayment({required String paymentId}) async {
    try {
      state = const AsyncValue.loading();

      if (_campId == null) {
        throw Exception('Camp ID not available');
      }

      await _repository.removePayment(_campId!, paymentId);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updatePayment({
    required String paymentId,
    String? name,
    int? amount,
    String? currency,
  }) async {
    try {
      state = const AsyncValue.loading();

      if (_campId == null) {
        throw Exception('Camp ID not available');
      }

      await _repository.updatePayment(
        campId: _campId!,
        paymentId: paymentId,
        name: name,
        amount: amount,
        currency: currency,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Set user payment status (mark as paid or unpaid)
  /// isPaid: true means paid, false means unpaid
  Future<void> setUserPayment({
    required String paymentId,
    required String userId,
    required bool isPaid,
  }) async {
    try {
      state = const AsyncValue.loading();

      if (_campId == null) {
        throw Exception('Camp ID not available');
      }

      await _repository.setUserPayment(
        campId: _campId!,
        paymentId: paymentId,
        userId: userId,
        isPaid: isPaid,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
