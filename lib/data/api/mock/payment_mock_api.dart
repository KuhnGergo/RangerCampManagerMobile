import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/api/requests/payments_api.dart';

/// Mock provider for the PaymentApi service
final paymentMockApiProvider = Provider<PaymentMockApi>((ref) {
  return PaymentMockApi();
});

/// Mock API client for payment-related operations.
class PaymentMockApi implements PaymentsApi {
  // Reference to current user email from auth
  static String? _currentUserEmail;

  // Fixed camp ID to match CampMockApi.ongoingCampId
  static const String ongoingCampId = '550e8400-e29b-41d4-a716-446655440001';

  // Mock payment definitions (camp-level)
  static final Map<String, Map<String, dynamic>> _payments = {
    'payment-001': {
      'id': 'payment-001',
      'campId': ongoingCampId,
      'name': 'Registration Fee',
      'amount': 5000, // $50.00 in cents
      'currency': 'USD',
      'dueDate': DateTime(2025, 1, 15).toIso8601String(),
      'createdAt': DateTime(2024, 12, 1).toIso8601String(),
    },
    'payment-002': {
      'id': 'payment-002',
      'campId': ongoingCampId,
      'name': 'Activity Fee',
      'amount': 3000, // $30.00 in cents
      'currency': 'USD',
      'dueDate': DateTime(2025, 2, 1).toIso8601String(),
      'createdAt': DateTime(2024, 12, 1).toIso8601String(),
    },
    'payment-003': {
      'id': 'payment-003',
      'campId': ongoingCampId,
      'name': 'Accommodation Fee',
      'amount': 7500, // $75.00 in cents
      'currency': 'USD',
      'dueDate': DateTime(2025, 2, 15).toIso8601String(),
      'createdAt': DateTime(2024, 12, 1).toIso8601String(),
    },
  };

  // Mock user payment assignments (user-level)
  static final Map<String, Map<String, dynamic>> _userPayments = {
    'up-001': {
      'id': 'up-001',
      'userId': 'user-test-001',
      'paymentId': 'payment-001',
      'isPaid': true, // paid
      'isPending': false,
    },
    'up-002': {
      'id': 'up-002',
      'userId': 'user-test-001',
      'paymentId': 'payment-002',
      'isPaid': false, // unpaid
      'isPending': false,
    },
    'up-003': {
      'id': 'up-003',
      'userId': 'user-test-001',
      'paymentId': 'payment-003',
      'isPaid': false, // unpaid
      'isPending': false,
    },
    'up-004': {
      'id': 'up-004',
      'userId': 'user-tobias-002',
      'paymentId': 'payment-001',
      'isPaid': true, // paid
      'isPending': false,
    },
    'up-005': {
      'id': 'up-005',
      'userId': 'user-tobias-002',
      'paymentId': 'payment-002',
      'isPaid': false, // unpaid
      'isPending': false,
    },
  };

  // User email to user ID mapping (synced with AuthMockApi)
  static final Map<String, String> _emailToUserId = {
    'user@gmail.com': 'user-test-001',
    'tobias@example.com': 'user-tobias-002',
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> removePayment(String campId, String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final payment = _payments[paymentId];
    if (payment == null || payment['campId'] != campId) {
      throw Exception('Payment not found');
    }

    _payments.remove(paymentId);
    _userPayments.removeWhere(
      (_, userPayment) => userPayment['paymentId'] == paymentId,
    );
  }

  @override
  Future<void> updatePayment({
    required String campId,
    required String paymentId,
    String? name,
    int? amount,
    String? currency,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final payment = _payments[paymentId];
    if (payment == null || payment['campId'] != campId) {
      throw Exception('Payment not found');
    }

    if (name != null) {
      payment['name'] = name;
    }
    if (amount != null) {
      payment['amount'] = amount;
    }
    if (currency != null) {
      payment['currency'] = currency.toUpperCase();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentsByCamp(String campId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (_currentUserEmail == null) {
      throw Exception('User not authenticated');
    }

    final userId = _emailToUserId[_currentUserEmail];
    if (userId == null) {
      throw Exception('User not found');
    }

    // Get all payments for the camp
    final campPayments = _payments.values
        .where((payment) => payment['campId'] == campId)
        .toList();

    // Get user payment statuses for this user
    final userPaymentStatuses = _userPayments.values
        .where((up) => up['userId'] == userId)
        .toList();

    // Build a map for quick lookup
    final statusMap = <String, Map<String, dynamic>>{};
    for (var up in userPaymentStatuses) {
      statusMap[up['paymentId']] = up;
    }

    // Combine payment definitions with user statuses
    final result = <Map<String, dynamic>>[];
    for (var payment in campPayments) {
      final userPayment = statusMap[payment['id']];
      if (userPayment != null) {
        result.add({
          ...payment,
          'userId': userId,
          'isPaid': userPayment['isPaid'],
          'isPending': userPayment['isPending'],
          'userPaymentId': userPayment['id'],
        });
      }
    }

    return result;
  }

  // Helper method to sync current user with auth mock
  static void setCurrentUser(String? email) {
    _currentUserEmail = email;
  }

  // Helper to add new payment definitions (for testing)
  static void createPayment(Map<String, dynamic> payment) {
    _payments[payment['id']] = payment;
  }

  // Helper to add user payment assignment (for testing)
  static void addUserPayment(Map<String, dynamic> userPayment) {
    _userPayments[userPayment['id']] = userPayment;
  }

  // Helper to clear all data (for testing)
  static void clearPayments() {
    _payments.clear();
    _userPayments.clear();
  }
}
