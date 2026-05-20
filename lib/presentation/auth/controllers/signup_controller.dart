import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/auth/providers/email_provider.dart';
import 'package:mastercs_mobile/core/api/api.dart';
import 'package:mastercs_mobile/providers/auth/session_flow.dart';
import 'package:mastercs_mobile/providers/connection/connectivity_provider.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';

/// Provider for the Signup state and logic
final signupController =
    NotifierProvider.autoDispose<SignupController, SignupState>(() {
      return SignupController();
    });

class SignupController extends Notifier<SignupState> {
  @override
  SignupState build() {
    // Listen to connectivity changes
    ref.listen<AsyncValue<InternetStatus>>(connectivityProvider, (
      previous,
      next,
    ) {
      next.whenData((connectivityState) {
        if (!connectivityState.isOnline) {
          state = state.copyWith(isOnline: false);
        } else {
          state = state.copyWith(isOnline: true);
        }
      });
    });

    return SignupState(email: ref.watch(emailProvider));
  }

  void updateForErrorToast() {
    if (state.isOnline == false) {
      state = state.copyWith(isOnline: false);
    }
  }

  void clearErrorMessage() {
    state = state.copyWith(errorMessage: null);
  }

  void nextPage() {
    if (state.currentPage < SignupState.dataCount - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void goToPage(int pageIndex) {
    if (state.currentPage != pageIndex) {
      state = state.copyWith(
        currentPage: pageIndex,
        returnToSummaryPage: state.currentPage == SignupState.dataCount - 1,
      );
    }
  }

  void goToSummaryPage() {
    state = state.copyWith(
      currentPage: SignupState.dataCount - 1,
      returnToSummaryPage: false,
    );
  }

  void updateCurrentPage(int pageIndex) {
    state = state.copyWith(currentPage: pageIndex);
  }

  Future<void> createAccount() async {
    state = state.copyWith(isCreatingAccount: true);

    try {
      if (state.isOnline == false) {
        // Cannot create account while offline
        state = state.copyWith(isCreatingAccount: false, isOnline: false);
        return;
      }

      // Register account
      await ref
          .read(sessionFlowProvider.notifier)
          .register(
            email: state.email,
            name: state.username,
            password: state.password,
            phoneNumber: state.phoneNumber,
            emergencyContact: state.emergencyContact,
          );

      // Reset email provider state so it doesn't think user exists
      ref.read(emailProvider.notifier).resetEmailExistence();

      state = state.copyWith(isLoginSuccessful: true);
      return;
    } catch (e) {
      if (e is ApiException) {
        state = state.copyWith(
          isCreatingAccount: false,
          isLoginSuccessful: false,
          errorMessage: e.message,
        );
        return;
      }
      state = state.copyWith(
        isCreatingAccount: false,
        isLoginSuccessful: false,
        errorMessage: 'Unexpected error. Please try again later.',
      );
      return;
    }
  }

  void saveAndNextUsername(String username) {
    state = state.copyWith(username: username);
    nextPage();
  }

  void saveAndNextPassword(String password) {
    state = state.copyWith(password: password);
    nextPage();
  }

  void saveAndNextPhoneNumber(String? phoneNumber) {
    state = state.copyWith(phoneNumber: phoneNumber);
    nextPage();
  }

  void saveAndNextEmergencyContact(String? emergencyContact) {
    state = state.copyWith(emergencyContact: emergencyContact);
    nextPage();
  }
}

class SignupState {
  final String email;
  final bool? isOnline;
  final String username;
  final String password;
  final String? phoneNumber;
  final String? emergencyContact;
  static const int dataCount = 5;
  final int currentPage;
  final bool isCreatingAccount;
  final bool isLoginSuccessful;
  final bool returnToSummaryPage;
  final String? errorMessage;

  SignupState({
    required this.email,
    this.isOnline,
    this.username = '',
    this.password = '',
    this.phoneNumber,
    this.emergencyContact,
    this.currentPage = 0,
    this.isCreatingAccount = false,
    this.isLoginSuccessful = false,
    this.returnToSummaryPage = false,
    this.errorMessage,
  });

  SignupState copyWith({
    String? email,
    String? username,
    String? password,
    String? phoneNumber,
    String? emergencyContact,
    int? currentPage,
    bool? isCreatingAccount,
    bool? isLoginSuccessful,
    bool? isOnline,
    bool? returnToSummaryPage,
    String? errorMessage,
  }) {
    return SignupState(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isCreatingAccount: isCreatingAccount ?? this.isCreatingAccount,
      currentPage: currentPage ?? this.currentPage,
      isLoginSuccessful: isLoginSuccessful ?? this.isLoginSuccessful,
      isOnline: isOnline ?? this.isOnline,
      returnToSummaryPage: returnToSummaryPage ?? this.returnToSummaryPage,
      errorMessage: errorMessage,
    );
  }
}
