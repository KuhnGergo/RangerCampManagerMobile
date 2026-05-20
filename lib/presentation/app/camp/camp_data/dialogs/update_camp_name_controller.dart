import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';

final updateCampNameControllerProvider =
    NotifierProvider.autoDispose<UpdateCampNameController, UpdateCampNameState>(
      () => UpdateCampNameController(),
    );

class UpdateCampNameController extends Notifier<UpdateCampNameState> {
  late final _campActionsProvider = ref.read(campActionsProvider.notifier);
  late final TextEditingController nameController;

  @override
  UpdateCampNameState build() {
    nameController = TextEditingController();

    ref.onDispose(() {
      nameController.dispose();
    });

    return const UpdateCampNameState();
  }

  void initialize(String currentName) {
    nameController.text = currentName;
    state = state.copyWith(name: currentName);
  }

  void updateName(String value) {
    state = state.copyWith(name: value, error: null);
  }

  String? validateName() {
    if (state.name.trim().isEmpty) {
      return 'Camp name is required';
    }
    if (state.name.trim().length < 3) {
      return 'Camp name must be at least 3 characters';
    }
    return null;
  }

  Future<void> updateCampName() async {
    final validationError = validateName();
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return;
    }

    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      await _campActionsProvider.updateCampDetails(name: state.name.trim());
      state = state.copyWith(isUpdating: false, success: true);
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString().replaceAll('Exception: ', ''),
        success: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class UpdateCampNameState {
  final String name;
  final bool isUpdating;
  final bool success;
  final String? error;

  const UpdateCampNameState({
    this.name = '',
    this.isUpdating = false,
    this.success = false,
    this.error,
  });

  UpdateCampNameState copyWith({
    String? name,
    bool? isUpdating,
    bool? success,
    String? error,
  }) {
    return UpdateCampNameState(
      name: name ?? this.name,
      isUpdating: isUpdating ?? this.isUpdating,
      success: success ?? this.success,
      error: error,
    );
  }
}
