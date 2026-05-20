import 'package:drift/drift.dart';

class UserPayments extends Table {
  TextColumn get userRemoteId => text()();
  TextColumn get paymentRemoteId => text()();
  BoolColumn get isPaid => boolean().clientDefault(() => false)();

  @override
  Set<Column> get primaryKey => {userRemoteId, paymentRemoteId};
}
