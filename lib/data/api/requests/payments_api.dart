import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api.dart';

final paymentsApiProvider = Provider<PaymentsApi>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final endpoints = ref.watch(endpointsProvider);
  return PaymentsApi(httpClient, endpoints);
});

class PaymentsApi {
  final ApiHttpClient _client;
  final Endpoints _endpoints;

  PaymentsApi(this._client, this._endpoints);

  /// Get all payments for a camp with user payment status
  /// Returns list of payments with their associated user payment statuses
  Future<List<Map<String, dynamic>>> getPaymentsByCamp(String campId) async {
    final response = await _client.get(_endpoints.getPaymentsByCamp(campId));
    return (response.jsonOrThrow['data'] as List).cast<Map<String, dynamic>>();
  }

  /// Add a new payment to a camp
  Future<void> addPayment({
    required String campId,
    required String name,
    DateTime? dueDate,
    required int amount,
    String currency = 'HUF',
  }) async {
    final response = await _client.post(
      _endpoints.createPayment(campId),
      body: {
        'name': name,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        'amount': amount,
        'currency': currency.toUpperCase(),
      },
    );
    response.throwIfError();
  }

  /// Remove a payment from a camp
  Future<void> removePayment(String campId, String paymentId) async {
    final response = await _client.delete(
      _endpoints.deletePayment(campId, paymentId),
    );
    response.throwIfError();
  }

  /// Update payment properties.
  Future<void> updatePayment({
    required String campId,
    required String paymentId,
    String? name,
    int? amount,
    String? currency,
  }) async {
    final response = await _client.patch(
      _endpoints.updatePayment(campId, paymentId),
      body: {
        if (name != null) 'name': name,
        if (amount != null) 'amount': amount,
        if (currency != null) 'currency': currency.toUpperCase(),
      },
    );
    response.throwIfError();
  }

  /// Update user payment status
  Future<void> setUserPayment({
    required String campId,
    required String paymentId,
    required String userId,
    required bool isPaid,
  }) async {
    final response = await _client.patch(
      _endpoints.updateUserPayment(campId, userId, paymentId),
      body: {'state': isPaid ? 'paid' : 'unpaid'},
    );
    response.throwIfError();
  }
}
