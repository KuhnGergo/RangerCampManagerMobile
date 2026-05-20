import 'package:drift/drift.dart';

class Payments extends Table {
  TextColumn get remoteId => text()();

  TextColumn get campRemoteId => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get amount => integer()(); // Amount in cents

  TextColumn get currency => text().withDefault(const Constant('USD'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {remoteId};
}
