import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mastercs_mobile/repositories/auth_repository.dart';

final authProvider = AsyncNotifierProvider<AuthProvider, bool>(() {
  return AuthProvider();
});

class AuthProvider extends AsyncNotifier<bool> {
  late final _authRepository = ref.read(authRepositoryProvider);
  final safeStorage = FlutterSecureStorage();

  String? _token;
  String? _userId;

  bool get isLoggedIn => _token != null;
  String? get getToken => _token;

  String? get getUserId => _userId;

  @override
  Future<bool> build() async {
    await _initAuth();
    return isLoggedIn;
  }

  Future<void> _initAuth() async {
    await tryAutoLogin();
  }

  Future<void> login(String email, String password) async {
    final result = await _authRepository.login(email, password);

    // On error Repository will throw exception, so if we are here, login was successful
    _token = result['token'];
    _userId = result['userId'];

    state = AsyncData(true);
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    String? profilePicturePath,
    String? phoneNumber,
    String? emergencyContact,
  }) async {
    final result = await _authRepository.register(
      email: email,
      password: password,
      username: username,
      profilePicturePath: profilePicturePath,
      phoneNumber: phoneNumber,
      emergencyContact: emergencyContact,
    );

    // After registration, automatically log in the user
    _token = result['token'];
    _userId = result['userId'];

    state = AsyncData(true);
  }

  Future<bool> hasUser(String email) async {
    return await _authRepository.hasUser(email);
  }

  Future<void> forgotPassword(String email) async {
    await _authRepository.forgotPassword(email);
  }

  Future<void> logout({bool fireApi = true}) async {
    _token = null;
    await _authRepository.logout(fireApi: fireApi);
    state = AsyncData(false);
  }

  Future<void> tryAutoLogin() async {
    final result = await _authRepository.tryAutoLogin();
    _token = result?['token'];
    _userId = result?['userId'];

    if (_token != null) {
      state = AsyncData(true);
    } else {
      state = AsyncData(false);
    }
  }
}
