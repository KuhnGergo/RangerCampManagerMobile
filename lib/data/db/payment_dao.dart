import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/core/schema/tables/payments_table.dart';
import 'package:mastercs_mobile/core/schema/tables/user_payments_table.dart';

part 'payment_dao.g.dart';

final paymentDaoProvider = Provider<PaymentDao>((ref) {
  final database = ref.watch(databaseProvider);
  return PaymentDao(database);
});

@DriftAccessor(tables: [Payments, UserPayments])
class PaymentDao extends DatabaseAccessor<AppDatabase> with _$PaymentDaoMixin {
  PaymentDao(super.db);

  /// Convert API payment response to PaymentsCompanion
  PaymentsCompanion toCompanion({
    required String id,
    required String campId,
    required String name,
    DateTime? dueDate,
    required int amount,
    String currency = 'USD',
  }) {
    return PaymentsCompanion(
      remoteId: Value(id),
      campRemoteId: Value(campId),
      name: Value(name),
      dueDate: Value(dueDate),
      amount: Value(amount),
      currency: Value(currency),
    );
  }

  Stream<List<Payment>> watchPaymentsByCamp(String campId) {
    return (select(
      payments,
    )..where((tbl) => tbl.campRemoteId.equals(campId))).watch();
  }

  Future<void> deletePaymentById(String paymentId) async {
    await (delete(
      payments,
    )..where((tbl) => tbl.remoteId.equals(paymentId))).go();
  }

  Future<void> updatePaymentById({
    required String paymentId,
    String? name,
    int? amount,
    String? currency,
  }) async {
    await (update(
      payments,
    )..where((tbl) => tbl.remoteId.equals(paymentId))).write(
      PaymentsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        amount: amount != null ? Value(amount) : const Value.absent(),
        currency: currency != null
            ? Value(currency.toUpperCase())
            : const Value.absent(),
      ),
    );
  }

  Future<void> createPayment(PaymentsCompanion companion) async {
    await into(payments).insert(companion);
  }

  Future<void> deletePaymentsByCampId(String campId) async {
    await (delete(
      payments,
    )..where((tbl) => tbl.campRemoteId.equals(campId))).go();
  }
}
