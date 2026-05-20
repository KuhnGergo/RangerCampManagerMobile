import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/repositories/account_repository.dart';
import 'package:mastercs_mobile/utils/validators.dart';

final editAccountControllerProvider =
    NotifierProvider.autoDispose<EditAccountController, EditAccountState>(
      () => EditAccountController(),
    );

class EditAccountController extends Notifier<EditAccountState> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController imageUrlController;

  @override
  EditAccountState build() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    imageUrlController = TextEditingController();

    ref.onDispose(() {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      imageUrlController.dispose();
    });

    return const EditAccountState();
  }

  void initialize({
    required String name,
    required String email,
    String? phoneNumber,
    String? imageUrl,
  }) {
    nameController.text = name;
    emailController.text = email;
    phoneController.text = phoneNumber ?? '';
    imageUrlController.text = imageUrl ?? '';
  }

  void setNameError(String? error) {
    state = state.copyWith(nameError: error);
  }

  void setEmailError(String? error) {
    state = state.copyWith(emailError: error);
  }

  void setPhoneError(String? error) {
    state = state.copyWith(phoneError: error);
  }

  void clearErrors() {
    state = state.copyWith(nameError: null, emailError: null, phoneError: null);
  }

  void resetNavigateBack() {
    state = state.copyWith(navigateBack: false);
  }

  void handleSave() async {
    // Validate all fields
    final nameError = Validators.username(nameController.text);
    final emailError = Validators.email(emailController.text);
    final phoneError = phoneController.text.isNotEmpty
        ? Validators.phoneNumber(phoneController.text)
        : null;

    setNameError(nameError);
    setEmailError(emailError);
    setPhoneError(phoneError);

    // If any validation fails, return early
    if (nameError != null || emailError != null || phoneError != null) {
      state = state.copyWith(
        nameError: nameError,
        emailError: emailError,
        phoneError: phoneError,
      );
      return;
    }

    // Save changes
    final success = await saveChanges();

    if (!success) {
      state = state.copyWith(
        navigateBack: true,
        error: 'Failed to save changes',
      );
    }
  }

  Future<bool> saveChanges() async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repository = ref.read(accountRepositoryProvider);
      await repository.updateAccount(
        name: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
        profilePicture: imageUrlController.text.isEmpty
            ? null
            : imageUrlController.text,
      );

      state = state.copyWith(
        isSubmitting: false,
        success: true,
        navigateBack: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

class EditAccountState {
  final bool isSubmitting;
  final bool success;
  final String? nameError;
  final String? emailError;
  final String? phoneError;
  final String? error;
  final bool navigateBack;

  const EditAccountState({
    this.isSubmitting = false,
    this.success = false,
    this.nameError,
    this.emailError,
    this.phoneError,
    this.error,
    this.navigateBack = false,
  });

  EditAccountState copyWith({
    bool? isSubmitting,
    bool? success,
    String? nameError,
    String? emailError,
    String? phoneError,
    String? error,
    bool? navigateBack,
  }) {
    return EditAccountState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      success: success ?? this.success,
      nameError: nameError,
      emailError: emailError,
      phoneError: phoneError,
      error: error,
      navigateBack: navigateBack ?? this.navigateBack,
    );
  }
}
