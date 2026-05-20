import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';
import 'package:mastercs_mobile/utils/validators.dart';

final joinCampScreenControllerProvider =
    NotifierProvider.autoDispose<JoinCampScreenController, JoinCampScreenState>(
      () {
        return JoinCampScreenController();
      },
    );

class JoinCampScreenController extends Notifier<JoinCampScreenState> {
  late final campActions = ref.read(campActionsProvider.notifier);

  @override
  JoinCampScreenState build() {
    return const JoinCampScreenState();
  }

  void updateCode(String code) {
    state = state.copyWith(code: code, error: null);
  }

  void clearCode() {
    state = state.copyWith(code: '', error: null, success: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void cancelLoading() {
    state = state.copyWith(isJoining: false, error: null);
  }

  void setCodeFromQR(String code) {
    state = state.copyWith(code: code);
  }

  void resetState() {
    state = const JoinCampScreenState();
  }

  Future<void> joinCamp() async {
    final code = state.code.trim();

    // Validate the code
    final validationError = Validators.joinCode(code);
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return;
    }

    if (state.isJoining) return;

    state = state.copyWith(isJoining: true, error: null);

    try {
      await campActions.joinCamp(code);
      state = state.copyWith(isJoining: false, success: true);
    } on NotFoundException {
      state = state.copyWith(
        isJoining: false,
        error: 'Camp not found with this join code',
        success: false,
      );
    } catch (e) {
      dev.log('Error joining camp: $e', name: 'JoinCampScreenController');
      state = state.copyWith(
        isJoining: false,
        error: 'Failed to join camp',
        success: false,
      );
    }
  }
}

class JoinCampScreenState {
  final String code;
  final bool isJoining;
  final bool success;
  final String? error;

  const JoinCampScreenState({
    this.code = '',
    this.isJoining = false,
    this.success = false,
    this.error,
  });

  JoinCampScreenState copyWith({
    String? code,
    bool? isJoining,
    bool? success,
    String? error,
  }) {
    return JoinCampScreenState(
      code: code ?? this.code,
      isJoining: isJoining ?? this.isJoining,
      success: success ?? this.success,
      error: error,
    );
  }
}
