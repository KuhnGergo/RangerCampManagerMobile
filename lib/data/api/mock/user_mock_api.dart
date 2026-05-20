import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/api/requests/user_api.dart';

/// Mock provider for the UserApi service
final userMockApiProvider = Provider<UserMockApi>((ref) {
  return UserMockApi();
});

/// Mock API client for user-related operations.
class UserMockApi implements UserApi {
  // Reference to auth mock to access current user
  static String? _currentUserEmail;

  // Mock user database (synced with AuthMockApi)
  static final Map<String, Map<String, dynamic>> _users = {
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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  // ===== Account Operations (for current authenticated user) =====

  @override
  Future<Map<String, dynamic>> getMyAccount({String? userId}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get current user from auth state
    String? userEmail = _currentUserEmail;

    // If _currentUserEmail is null (e.g., after app restart), try to find by userId
    if (userEmail == null && userId != null) {
      // Find user by ID and restore _currentUserEmail
      for (var entry in _users.entries) {
        if (entry.value['id'] == userId) {
          userEmail = entry.key;
          _currentUserEmail = userEmail;
          break;
        }
      }
    }

    if (userEmail == null) {
      throw Exception('User not authenticated');
    }

    final user = _users[userEmail];
    if (user == null) {
      throw Exception('User not found');
    }

    return {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'phoneNumber': user['phoneNumber'],
      'profilePicturePath': user['profilePicturePath'],
      'emergencyContact': user['emergencyContact'],
    };
  }

  @override
  Future<Map<String, dynamic>> updateMyAccount({
    required String name,
    required String email,
    String? phoneNumber,
    String? profilePicture,
    String? emergencyContact,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final userEmail = _currentUserEmail;
    if (userEmail == null) {
      throw Exception('User not authenticated');
    }

    final user = _users[userEmail];
    if (user == null) {
      throw Exception('User not found');
    }

    // Update user data
    user['name'] = name;
    user['phoneNumber'] = phoneNumber;
    user['profilePicturePath'] = profilePicture;
    user['emergencyContact'] = emergencyContact;

    // If email changed, update the map key
    final oldEmail = user['email'] as String;
    if (email.toLowerCase() != oldEmail.toLowerCase()) {
      user['email'] = email;
      _users[email.toLowerCase()] = user;
      _users.remove(oldEmail.toLowerCase());
      _currentUserEmail = email.toLowerCase();

      // Sync with AuthMockApi
      // Note: This is a simplified version; in production, email changes would require verification
    }

    // Return updated user data
    return {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'phoneNumber': user['phoneNumber'],
      'profilePicturePath': user['profilePicturePath'],
      'emergencyContact': user['emergencyContact'],
    };
  }

  @override
  Future<void> deleteMyAccount() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final userEmail = _currentUserEmail;
    if (userEmail == null) {
      throw Exception('User not authenticated');
    }

    _users.remove(userEmail);
    _currentUserEmail = null;
  }

  // ===== User Retrieval Operations (for general users) =====

  Future<Map<String, dynamic>> getUser(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find user by ID
    final user = _users.values.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => throw Exception('User not found'),
    );

    return {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'phoneNumber': user['phoneNumber'],
      'profilePicturePath': user['profilePicturePath'],
      'emergencyContact': user['emergencyContact'],
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getUsersByCamp(String campId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // For mock, return some sample users
    // In real implementation, this would filter by camp membership
    return _users.values
        .map(
          (user) => {
            'id': user['id'],
            'name': user['name'],
            'email': user['email'],
            'phoneNumber': user['phoneNumber'],
            'profilePicturePath': user['profilePicturePath'],
            'emergencyContact': user['emergencyContact'],
          },
        )
        .take(5)
        .toList();
  }

  // Helper method to sync current user with auth mock
  static void setCurrentUser(String? email) {
    _currentUserEmail = email;
  }

  // Helper to sync user data with AuthMockApi
  static void syncUsers(Map<String, Map<String, dynamic>> users) {
    _users.clear();
    _users.addAll(users);
  }
}
