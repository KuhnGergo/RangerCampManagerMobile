import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api.dart';
import 'package:mastercs_mobile/providers/actions/account_actions_provider.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';
import 'package:mastercs_mobile/providers/notifications/firebase_notification_provider.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/providers/socket/socket_manager.dart';
import 'package:mastercs_mobile/providers/socket/socket_provider.dart';

final sessionFlowProvider = AsyncNotifierProvider<SessionFlow, void>(() {
  return SessionFlow();
});

class SessionFlow extends AsyncNotifier<void> {
  late final AuthProvider _authProvider;
  late final AccountActionsProvider _accountActionsProvider;
  late final CampActionsProvider _campActionsProvider;
  late final FirebaseNotificationProvider _firebaseNotificationProvider;
  late final AppDatabase _databaseProvider;

  Future<void> _resetSocketLayer({required String reason}) async {
    final socketService = ref.read(socketServiceProvider);
    await socketService.stopSession(clearPendingEmits: true, forLogout: true);
  }

  Future<void> _startSocketLayer({required String reason}) async {
    final token = _authProvider.getToken;
    if (token == null || token.isEmpty) {
      return;
    }

    final manager = ref.read(socketManagerProvider.notifier);
    final socketService = ref.read(socketServiceProvider);

    // Keep reconnect entrypoint available for queued emits.
    socketService.setReconnectRequest(manager.reconnect);

    await socketService.startSession(token, enableReconnection: true);
    await socketService.waitUntilReady();
  }

  @override
  Future<void> build() async {
    _authProvider = ref.read(authProvider.notifier);
    _accountActionsProvider = ref.read(accountActionsProvider.notifier);
    _campActionsProvider = ref.read(campActionsProvider.notifier);
    _firebaseNotificationProvider = ref.read(
      firebaseNotificationProvider.notifier,
    );
    _databaseProvider = ref.read(databaseProvider);
  }

  Future<void> logout({bool deletedAccount = false}) async {
    state = const AsyncValue.loading();
    try {
      await _authProvider.logout(
        fireApi: !deletedAccount,
      ); // Clear token from secure storage
      await _resetSocketLayer(reason: 'logout');
      await _campActionsProvider
          .clear(); // Clear memory, and campId from SharedPreferences
      await _databaseProvider.clearDatabase(); // Clear local database
      await _firebaseNotificationProvider.stopTokenRefreshListener();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteAccountAndLogout(String newCampId) async {
    state = const AsyncValue.loading();
    try {
      await _accountActionsProvider
          .deleteAccount(); // Delete account from API and local DB
      await logout(deletedAccount: true); // Perform full logout
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      // SessionFlow owns the hard boundary between user sessions.
      await _resetSocketLayer(reason: 'pre_login_reset');

      await _authProvider.login(
        email,
        password,
      ); // Store token in secure storage

      // Bring up a fresh socket service/manager bound to the new token.
      await _startSocketLayer(reason: 'login_success');

      await _campActionsProvider
          .refreshCamps(); // Load camps from API and store in local DB
      await _accountActionsProvider
          .refreshMyAccount(); // Load user data from API and store in local DB

      // Notification registration should not block a successful login flow.
      try {
        await _firebaseNotificationProvider.setToken();
      } catch (_) {}

      state = const AsyncValue.data(null);
    } on UnauthorizedException catch (_) {
      throw UnauthorizedException();
    } on ForbiddenException catch (_) {
      throw ForbiddenException();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? emergencyContact,
    String? phoneNumber,
    String? profilePicturePath,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authProvider.register(
        email: email,
        password: password,
        username: name,
        emergencyContact: emergencyContact,
        phoneNumber: phoneNumber,
        profilePicturePath: profilePicturePath,
      );
      await _accountActionsProvider
          .refreshMyAccount(); // Load user data from API and store in local DB
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
