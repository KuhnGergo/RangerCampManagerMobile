import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/core/schema/tables/payments_table.dart';
import 'package:mastercs_mobile/core/schema/tables/user_payments_table.dart';

part 'user_payment_dao.g.dart';

final userPaymentDaoProvider = Provider<UserPaymentDao>((ref) {
  final database = ref.watch(databaseProvider);
  return UserPaymentDao(database);
});

@DriftAccessor(tables: [UserPayments, Payments])
class UserPaymentDao extends DatabaseAccessor<AppDatabase>
    with _$UserPaymentDaoMixin {
  UserPaymentDao(super.db);

  /// Convert API user payment response to UserPaymentsCompanion
  UserPaymentsCompanion toCompanion({
    required String userRemoteId,
    required String paymentRemoteId,
    required bool isPaid,
  }) {
    return UserPaymentsCompanion(
      userRemoteId: Value(userRemoteId),
      paymentRemoteId: Value(paymentRemoteId),
      isPaid: Value(isPaid),
    );
  }

  Future<void> upsertManyUserPayments(
    List<UserPaymentsCompanion> companions,
  ) async {
    for (final companion in companions) {
      await into(userPayments).insertOnConflictUpdate(companion);
    }
  }

  Future<void> upsertUserPayment(UserPaymentsCompanion companion) async {
    await into(userPayments).insertOnConflictUpdate(companion);
  }

  Future<void> deleteUserPaymentsByPaymentId(String paymentId) async {
    await (delete(
      userPayments,
    )..where((tbl) => tbl.paymentRemoteId.equals(paymentId))).go();
  }

  /// Select all user payments for a given camp
  /// Maps userId and PaymentId to isPaid status
  Stream<Map<String, Map<String, bool>>> watchAllUserPaymentsByCamp(
    String campId,
  ) {
    // Join UserPayments with Payments to be able to filter by campId
    final query = select(userPayments).join([
      innerJoin(
        payments,
        userPayments.paymentRemoteId.equalsExp(payments.remoteId),
      ),
    ])..where(payments.campRemoteId.equals(campId));

    // Convert the query result into the desired map structure
    return query.watch().map((rows) {
      final Map<String, Map<String, bool>> result = {};
      for (final row in rows) {
        final userPayment = row.readTable(userPayments);

        // Initialize map inside map entry if not present (indexed matrix style)
        result.putIfAbsent(userPayment.userRemoteId, () => {});
        // Set the paymentId to isPaid status
        result[userPayment.userRemoteId]![userPayment.paymentRemoteId] =
            userPayment.isPaid;
      }
      return result;
    });
  }
}
