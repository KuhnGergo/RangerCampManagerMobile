import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api_exception_types.dart';
import 'package:mastercs_mobile/presentation/auth/providers/email_provider.dart';
import 'package:mastercs_mobile/providers/auth/session_flow.dart';
import 'package:mastercs_mobile/providers/connection/connectivity_provider.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';
import 'package:mastercs_mobile/utils/validators.dart';

/// Provider for the Login state and logic
final loginController =
    NotifierProvider.autoDispose<LoginController, LoginState>(() {
      return LoginController();
    });

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() {
    return LoginState(email: ref.watch(emailProvider));
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, errorText: null);
  }

  void removeError() {
    state = state.copyWith(errorText: null);
  }

  void setSentTime() {
    state = state.copyWith(lastEmailSentTime: DateTime.now());
  }

  void submit() async {
    try {
      final error = Validators.password(state.password);

      state = state.copyWith(errorText: error);

      if (error != null) {
        return;
      }

      state = state.copyWith(isSubmitting: true);

      // Check internet connection
      if (!ref.read(connectivityProvider).value!.isOnline) {
        state = state.copyWith(
          isSubmitting: false,
          errorText: 'No internet connection.',
        );
        return;
      }

      await ref
          .read(sessionFlowProvider.notifier)
          .login(state.email, state.password);

      state = state.copyWith(isLoginSuccessful: true, isSubmitting: false);
      return;
    } on UnauthorizedException catch (_) {
      state = state.copyWith(
        errorText: 'Invalid password.',
        isSubmitting: false,
      );
    } on ForbiddenException catch (_) {
      state = state.copyWith(
        errorText: 'Please verify your email before logging in.',
        isSubmitting: false,
      );
    } catch (e) {
      // Általános hiba
      state = state.copyWith(
        errorText: 'Login failed. Please try again later.',
        isSubmitting: false,
      );
      return;
    }
  }
}

class LoginState {
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool isSubmitting;
  final bool isLoginSuccessful;
  String? errorText;
  DateTime? lastEmailSentTime;

  LoginState({
    required this.email,
    this.password = '',
    this.errorText,
    this.lastEmailSentTime,
    this.isPasswordVisible = false,
    this.isSubmitting = false,
    this.isLoginSuccessful = false,
  });

  LoginState copyWith({
    String? email,
    String? password,
    String? errorText,
    DateTime? lastEmailSentTime,
    bool? isPasswordVisible,
    bool? isSubmitting,
    bool? isLoginSuccessful,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      errorText: errorText,
      lastEmailSentTime: lastEmailSentTime ?? this.lastEmailSentTime,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoginSuccessful: isLoginSuccessful ?? this.isLoginSuccessful,
    );
  }
}
