import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/api/requests/payments_api.dart';
import 'package:mastercs_mobile/data/db/payment_dao.dart';
import 'package:mastercs_mobile/data/db/user_payment_dao.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final paymentDao = ref.watch(paymentDaoProvider);
  final paymentsApi = ref.watch(paymentsApiProvider);
  final userPaymentDao = ref.watch(userPaymentDaoProvider);
  final db = ref.watch(databaseProvider);

  return PaymentRepository(paymentDao, userPaymentDao, paymentsApi, db);
});

class PaymentRepository {
  final PaymentDao _paymentDao;
  final UserPaymentDao _userPaymentDao;
  final PaymentsApi _api;
  final AppDatabase _db;

  PaymentRepository(
    this._paymentDao,
    this._userPaymentDao,
    this._api,
    this._db,
  );

  Future<void> refreshPayments(String campId) async {
    // fetch payments from api
    final remotePayments = await _api.getPaymentsByCamp(campId);

    // convert to companions
    final paymentCompanions = remotePayments.map((remotePayment) {
      return _paymentDao.toCompanion(
        id: remotePayment['id'],
        campId: campId,
        name: remotePayment['paymentName'] ?? remotePayment['name'],
        dueDate: remotePayment['dueDate'] != null
            ? DateTime.parse(remotePayment['dueDate'])
            : null,
        currency: remotePayment['currency'],
        amount: remotePayment['amount'],
      );
    }).toList();

    // upsert data into local db
    await _db.transaction(() async {
      for (final companion in paymentCompanions) {
        await _paymentDao
            .into(_paymentDao.payments)
            .insertOnConflictUpdate(companion);
      }
    });
  }

  /// Update user payment status
  Future<void> setUserPayment({
    required String campId,
    required String paymentId,
    required String userId,
    required bool isPaid,
  }) async {
    await _api.setUserPayment(
      campId: campId,
      paymentId: paymentId,
      userId: userId,
      isPaid: isPaid,
    );
    await _userPaymentDao.upsertUserPayment(
      _userPaymentDao.toCompanion(
        userRemoteId: userId,
        paymentRemoteId: paymentId,
        isPaid: isPaid,
      ),
    );
  }

  /// Add a new payment to a camp
  Future<void> addPayment({
    required String campId,
    required String name,
    DateTime? dueDate,
    required int amount,
    String currency = 'HUF',
  }) async {
    await _api.addPayment(
      campId: campId,
      name: name,
      dueDate: dueDate,
      amount: amount,
      currency: currency,
    );
    refreshPayments(campId);
  }

  /// Remove a payment from a camp
  /// Also removes associated user payments via foreign key constraint
  Future<void> removePayment(String campId, String paymentId) async {
    await _api.removePayment(campId, paymentId);
    await _paymentDao.deletePaymentById(paymentId);
    await _userPaymentDao.deleteUserPaymentsByPaymentId(paymentId);
  }

  Future<void> updatePayment({
    required String campId,
    required String paymentId,
    String? name,
    int? amount,
    String? currency,
  }) async {
    await _api.updatePayment(
      campId: campId,
      paymentId: paymentId,
      name: name,
      amount: amount,
      currency: currency,
    );

    await _paymentDao.updatePaymentById(
      paymentId: paymentId,
      name: name,
      amount: amount,
      currency: currency,
    );
  }

  Future<void> deletePaymentsOfCamp(String campId) async {
    await _paymentDao.deletePaymentsByCampId(campId);
  }
}
