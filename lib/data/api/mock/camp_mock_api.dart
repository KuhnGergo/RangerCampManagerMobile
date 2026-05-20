// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/api/requests/camp_api.dart';
import 'package:uuid/uuid.dart';

/// Mock provider for the CampApi service
/// Use this in tests or for local development without a backend
final campMockApiProvider = Provider<CampMockApi>((ref) {
  return CampMockApi();
});

/// Mock API client for camp-related operations.
/// This class simulates the behavior of CampApi without making real HTTP requests.
class CampMockApi implements CampApi {
  // Simulate logged in state (set from auth mock)
  static String? currentUserEmail;

  // Fixed camp ID for consistent payment data
  static const String ongoingCampId = '550e8400-e29b-41d4-a716-446655440001';

  // Simulate a database of camps per user (static to persist across instances)
  static final Map<String, List<Map<String, dynamic>>> _userCamps = {
    'user@gmail.com': [
      {
        'id': ongoingCampId,
        'name': 'Ongoing Adventure Camp',
        'startDate': DateTime.now()
            .subtract(Duration(days: 3))
            .toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 4)).toIso8601String(),
        'minGroupSize': 5,
        'joinCode': 'ONGOING24',
        'createdAt': DateTime.now()
            .subtract(Duration(days: 30))
            .toIso8601String(),
        'updatedAt': DateTime.now()
            .subtract(Duration(days: 30))
            .toIso8601String(),
      },
      {
        'id': Uuid().v4(),
        'name': 'Starting Soon Camp',
        'startDate': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 14)).toIso8601String(),
        'minGroupSize': 8,
        'joinCode': 'SOON25',
        'createdAt': DateTime.now()
            .subtract(Duration(days: 15))
            .toIso8601String(),
        'updatedAt': DateTime.now()
            .subtract(Duration(days: 15))
            .toIso8601String(),
      },
      {
        'id': Uuid().v4(),
        'name': 'Future Summer Camp',
        'startDate': DateTime.now().add(Duration(days: 60)).toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 75)).toIso8601String(),
        'minGroupSize': 6,
        'joinCode': 'FUTURE25',
        'createdAt': DateTime.now()
            .subtract(Duration(days: 5))
            .toIso8601String(),
        'updatedAt': DateTime.now()
            .subtract(Duration(days: 5))
            .toIso8601String(),
      },
      {
        'id': Uuid().v4(),
        'name': 'Finished Winter Camp',
        'startDate': DateTime.now()
            .subtract(Duration(days: 30))
            .toIso8601String(),
        'endDate': DateTime.now()
            .subtract(Duration(days: 15))
            .toIso8601String(),
        'minGroupSize': 10,
        'joinCode': 'WINTER24',
        'createdAt': DateTime.now()
            .subtract(Duration(days: 60))
            .toIso8601String(),
        'updatedAt': DateTime.now()
            .subtract(Duration(days: 60))
            .toIso8601String(),
      },
      {
        'id': Uuid().v4(),
        'name': 'Tomorrow Start Camp',
        'startDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
        'endDate': DateTime.now().add(Duration(days: 5)).toIso8601String(),
        'minGroupSize': 4,
        'joinCode': 'TOMORROW',
        'createdAt': DateTime.now()
            .subtract(Duration(days: 10))
            .toIso8601String(),
        'updatedAt': DateTime.now()
            .subtract(Duration(days: 10))
            .toIso8601String(),
      },
    ],
    'tobias@example.com': [], // Tobias has no camps
  };

  // Available camps that can be joined (static to persist across instances)
  static final List<Map<String, dynamic>> _availableCamps = [
    {
      'id': Uuid().v4(),
      'name': 'Public Outdoor Camp',
      'startDate': DateTime(2025, 7, 1).toIso8601String(),
      'endDate': DateTime(2025, 7, 15).toIso8601String(),
      'minGroupSize': 4,
      'joinCode': 'PUBLIC25',
      'createdAt': DateTime.now()
          .subtract(Duration(days: 10))
          .toIso8601String(),
      'updatedAt': DateTime.now()
          .subtract(Duration(days: 10))
          .toIso8601String(),
    },
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Map<String, dynamic>> createCamp({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    int? minGroupSize,
    String? joinCode,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    String? userEmail = currentUserEmail?.toLowerCase();

    // Generate a new camp
    final newCamp = {
      'id': Uuid().v4(),
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (minGroupSize != null) 'minGroupSize': minGroupSize,
      'joinCode': joinCode ?? _generateJoinCode(),
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Add to user's camps
    if (userEmail == null) {
      for (var entry in _userCamps.entries) {
        entry.value.add(newCamp);
      }
      print('-----------------------------------');
      print('Added new camp for all users');
      print('Registered users might not see changes.');
      print('-----------------------------------');
    } else {
      if (!_userCamps.containsKey(userEmail)) {
        _userCamps[userEmail] = [];
      }
      _userCamps[userEmail]!.add(newCamp);
    }

    return Map<String, dynamic>.from(newCamp);
  }

  /// Generate a random join code
  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      6,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }

  @override
  Future<List<Map<String, dynamic>>> getMyCamps() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final userEmail = currentUserEmail?.toLowerCase();

    if (userEmail == null) {
      throw Exception('User not authenticated');
    }

    // Return user's camps or empty list if user has no camps
    return List<Map<String, dynamic>>.from(_userCamps[userEmail] ?? []);
  }

  @override
  Future<Map<String, dynamic>> joinCamp(String code) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final userEmail = currentUserEmail?.toLowerCase();

    if (userEmail == null) {
      throw Exception('User not authenticated');
    }

    // Find camp by join code
    final campIndex = _availableCamps.indexWhere(
      (camp) =>
          camp['joinCode']?.toString().toUpperCase() == code.toUpperCase(),
    );

    if (campIndex == -1) {
      throw Exception('Invalid join code');
    }

    final camp = Map<String, dynamic>.from(_availableCamps[campIndex]);

    // Check if user already joined this camp
    final userCampsList = _userCamps[userEmail] ?? [];
    final alreadyJoined = userCampsList.any((c) => c['id'] == camp['id']);

    if (alreadyJoined) {
      throw Exception('You have already joined this camp');
    }

    // Add camp to user's camps
    if (!_userCamps.containsKey(userEmail)) {
      _userCamps[userEmail] = [];
    }
    _userCamps[userEmail]!.add(camp);

    return camp;
  }

  @override
  Future<Map<String, dynamic>> getCamp(String campId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    final userEmail = currentUserEmail?.toLowerCase();

    if (userEmail == null) {
      throw Exception('User not authenticated');
    }

    final userCampsList = _userCamps[userEmail] ?? [];
    final camp = userCampsList.firstWhere(
      (c) => c['id'] == campId,
      orElse: () => throw Exception('Camp not found'),
    );

    return Map<String, dynamic>.from(camp);
  }

  @override
  Future<void> updateCamp({
    required String campId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    int? minGroupSize,
    String? joinCode,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final userEmail = currentUserEmail?.toLowerCase();

    if (userEmail == null) {
      throw Exception('User not authenticated');
    }

    final userCampsList = _userCamps[userEmail] ?? [];
    final campIndex = userCampsList.indexWhere((c) => c['id'] == campId);

    if (campIndex == -1) {
      throw Exception('Camp not found');
    }

    // Update the camp
    _userCamps[userEmail]![campIndex] = {
      ..._userCamps[userEmail]![campIndex],
      if (name != null) 'name': name,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
      if (minGroupSize != null) 'minGroupSize': minGroupSize,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<void> deleteCamp(String campId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final userEmail = currentUserEmail?.toLowerCase();

    if (userEmail == null) {
      throw Exception('User not authenticated');
    }

    final userCampsList = _userCamps[userEmail] ?? [];
    final campIndex = userCampsList.indexWhere((c) => c['id'] == campId);

    if (campIndex == -1) {
      throw Exception('Camp not found');
    }

    _userCamps[userEmail]!.removeAt(campIndex);
  }

  @override
  Future<void> leaveCamp(String campId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final userEmail = currentUserEmail?.toLowerCase();

    final userCampsList = _userCamps[userEmail] ?? [];
    final campIndex = userCampsList.indexWhere((c) => c['remoteId'] == campId);

    if (campIndex == -1) {
      throw Exception('Camp not found');
    }

    if (userEmail == null) {
      for (var key in _userCamps.keys) {
        final userCampsList = _userCamps[key] ?? [];
        final campIndex = userCampsList.indexWhere(
          (c) => c['remoteId'] == campId,
        );
        if (campIndex != -1) {
          _userCamps[key]!.removeAt(campIndex);
        }
      }
      return;
    }

    _userCamps[userEmail]!.removeAt(campIndex);
  }

  /// Helper method to set the current user (for testing)
  static void setCurrentUser(String? email) {
    currentUserEmail = email?.toLowerCase();
  }

  /// Helper method to add a camp for a specific user (for testing)
  static void addCampForUser(String userEmail, Map<String, dynamic> camp) {
    final email = userEmail.toLowerCase();
    if (!_userCamps.containsKey(email)) {
      _userCamps[email] = [];
    }
    _userCamps[email]!.add(camp);
  }

  /// Helper method to clear all camps for a user (for testing)
  static void clearCampsForUser(String userEmail) {
    final email = userEmail.toLowerCase();
    _userCamps[email] = [];
  }
}
