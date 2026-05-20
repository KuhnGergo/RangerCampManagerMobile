import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api_provider.dart';
import 'package:mastercs_mobile/data/api/endpoints.dart';
import 'package:mastercs_mobile/data/api/mock/camp_mock_api.dart';
import 'package:mastercs_mobile/data/api/requests/auth_api.dart';
import 'package:mastercs_mobile/data/api/mock/user_mock_api.dart';
import 'package:mastercs_mobile/data/api/mock/payment_mock_api.dart';

/// Mock provider for the AuthApi service
/// Use this in tests or for local development without a backend
final authMockApiProvider = Provider<AuthApi>((ref) {
  final Endpoints endpoints = ref.read(endpointsProvider);
  return AuthMockApi(endpoints);
});

/// Mock API client for authentication-related operations.
/// This class simulates the behavior of AuthApi without making real HTTP requests.
class AuthMockApi implements AuthApi {
  @override
  final Endpoints endpoints;

  AuthMockApi(this.endpoints);

  // Overrides
  @override
  Future<bool> hasUser(String email) => _hasUser(email);

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) => _login(email: email, password: password);

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
    String? profilePicturePath,
    String? phoneNumber,
    String? emergencyContact,
  }) => _register(
    email: email,
    password: password,
    username: username,
    profilePicturePath: profilePicturePath,
    phoneNumber: phoneNumber,
    emergencyContact: emergencyContact,
  );

  @override
  Future<void> logout() => _logout();

  @override
  Future<void> forgotPassword(String email) => _forgotPassword(email);

  // Simulate a database of users with fixed IDs
  final Map<String, Map<String, dynamic>> _users = {
    'user@gmail.com': {
      'email': 'user@gmail.com',
      'password': 'user123',
      'name': 'Test User',
      'phoneNumber': '+36-12-456-7890',
      'id': 'user-test-001',
    },
    'tobias@example.com': {
      'email': 'tobias@example.com',
      'password': 'tobias123',
      'name': 'Franz Tobias',
      'emergencyContact': '+36-98-765-4321',
      'id': 'user-tobias-002',
    },
  };

  // Simulate logged in state
  String? _currentUserEmail;

  Future<bool> _hasUser(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _users.containsKey(email.toLowerCase());
  }

  Future<Map<String, dynamic>> _login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final user = _users[email.toLowerCase()];

    if (user == null) {
      throw Exception('User not found');
    }

    if (user['password'] != password) {
      throw Exception('Invalid password');
    }

    _currentUserEmail = email.toLowerCase();

    // Sync with camp mock API
    CampMockApi.currentUserEmail = _currentUserEmail;

    // Sync with user mock API
    UserMockApi.setCurrentUser(_currentUserEmail);
    UserMockApi.syncUsers(_users);

    // Sync with payment mock API
    PaymentMockApi.setCurrentUser(_currentUserEmail);

    return {
      'user': {'id': user['id'], 'email': user['email'], 'name': user['name']},
      'token':
          'mock_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}',
      'camps': jsonEncode(await CampMockApi().getMyCamps()),
      'refreshToken': 'mock_refresh_token_${user['id']}',
    };
  }

  Future<Map<String, dynamic>> _register({
    required String email,
    required String password,
    required String username,
    String? profilePicturePath,
    String? phoneNumber,
    String? emergencyContact,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final lowercaseEmail = email.toLowerCase();

    if (_users.containsKey(lowercaseEmail)) {
      throw Exception('User already exists');
    }

    final newUserId = (_users.length + 1).toString();

    _users[lowercaseEmail] = {
      'email': lowercaseEmail,
      'password': password,
      'name': username,
      'id': newUserId,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
    };

    _currentUserEmail = lowercaseEmail;
    // Sync with camp mock API
    CampMockApi.currentUserEmail = _currentUserEmail;

    // Sync with user mock API
    UserMockApi.setCurrentUser(_currentUserEmail);
    UserMockApi.syncUsers(_users);

    // Sync with payment mock API
    PaymentMockApi.setCurrentUser(_currentUserEmail);

    return {
      'user': {
        'id': newUserId,
        'email': lowercaseEmail,
        'name': username,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (emergencyContact != null) 'emergencyContact': emergencyContact,
      },
      'token':
          'mock_token_${newUserId}_${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'mock_refresh_token_$newUserId',
    };
  }

  Future<void> _logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    _currentUserEmail = null;
    // Sync with camp mock API
    CampMockApi.currentUserEmail = null;

    // Sync with user mock API
    UserMockApi.setCurrentUser(null);

    // Sync with payment mock API
    PaymentMockApi.setCurrentUser(null);
  }

  Future<void> _forgotPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (!_users.containsKey(email.toLowerCase())) {
      throw Exception('User not found');
    }

    // In a real implementation, this would send a password reset email
    // For mock, we just simulate success
  }

  /// Helper method to check if a user is currently logged in (mock only)
  bool get isLoggedIn => _currentUserEmail != null;

  /// Helper method to get current user email (mock only)
  String? get currentUserEmail => _currentUserEmail;

  /// Helper method to reset mock state (useful for testing)
  void reset() {
    _currentUserEmail = null;
    _users.clear();
    _users.addAll({
      'test@example.com': {
        'email': 'test@example.com',
        'password': 'password123',
        'name': 'Test User',
        'id': '1',
      },
      'user@example.com': {
        'email': 'user@example.com',
        'password': 'password456',
        'name': 'Demo User',
        'id': '2',
      },
    });
  }
}
