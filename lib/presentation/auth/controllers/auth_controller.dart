import 'package:mastercs_mobile/core/api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/auth/providers/email_provider.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/connection/connectivity_provider.dart';
import 'package:mastercs_mobile/providers/connection/status_enum.dart';
import 'package:mastercs_mobile/utils/validators.dart';

final authController = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthController extends Notifier<AuthState> {
  late final AuthProvider _authProvider = ref.read(authProvider.notifier);

  static const internetErrorMessage = 'No internet connection.';

  @override
  AuthState build() {
    // Listen to connectivity changes
    ref.listen<AsyncValue<InternetStatus>>(connectivityProvider, (
      previous,
      next,
    ) {
      next.whenData((connectivityState) {
        // Only update error if there's no validation error
        if (state.errorMessage == null ||
            state.errorMessage!.isEmpty ||
            state.errorMessage == internetErrorMessage) {
          if (!connectivityState.isOnline) {
            // Internet went offline
            state = state.copyWith(errorMessage: internetErrorMessage);
          } else if (state.errorMessage == internetErrorMessage) {
            // Internet came back online, clear internet error
            state = state.copyWith(errorMessage: null);
          }
        }
      });
    });

    return AuthState(email: '');
  }

  void appendSuffix(String suffix) {
    final currentText = state.email;
    String baseEmail = currentText.contains('@')
        ? currentText.substring(0, currentText.indexOf('@'))
        : currentText;

    state = state.copyWith(email: baseEmail + suffix);

    removeError();
  }

  void setEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void removeError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetUserExistence() {
    state = state.copyWith(userExistence: UserExitstence.unknown);
  }

  /// E-mail ellenőrzése, elküldése, hibakezelés, átírányítás.
  void submit() async {
    // E-mail ellenőrzése
    final error = Validators.email(state.email);

    // Hibaüzenet megjelenítése
    state = state.copyWith(errorMessage: error);

    // Ha email nem érvényes kilép
    if (error != null) {
      return;
    }

    // Töltő állapot bekapcsolása, mert hálózati művelet indul
    state = state.copyWith(isSubmitting: true);
    try {
      final email = state.email;

      // Ellenőrzés, hogy van-e internet kapcsolat
      if (!ref.read(connectivityProvider).value!.isOnline) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: internetErrorMessage,
        );
        return;
      }

      final exists = await _authProvider.hasUser(email);

      ref.read(emailProvider.notifier).value = email;

      state = state.copyWith(
        isSubmitting: false,
        userExistence: exists
            ? UserExitstence.exists
            : UserExitstence.notExists,
      );
    } catch (e) {
      // Szerverhiba esetén a visszakapott hibaüzenet megjelenítése
      if (e is ApiException) {
        state = state.copyWith(isSubmitting: false, errorMessage: e.message);
        return;
      }
      // Váratlan hiba
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unexpected error. Please try again later.',
      );
    }
  }
}

enum UserExitstence { unknown, exists, notExists }

class AuthState {
  final String email;
  final bool isSubmitting;
  final String? errorMessage;
  final UserExitstence userExistence;

  AuthState({
    required this.email,
    this.isSubmitting = false,
    this.errorMessage,
    this.userExistence = UserExitstence.unknown,
  });

  AuthState copyWith({
    String? email,
    String? errorMessage,
    bool? isSubmitting,
    UserExitstence? userExistence,
  }) {
    return AuthState(
      email: email ?? this.email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      userExistence: userExistence ?? this.userExistence,
    );
  }
}
