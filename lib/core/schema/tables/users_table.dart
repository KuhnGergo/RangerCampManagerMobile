import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get remoteId => text()();

  TextColumn get name => text().withLength(min: 3, max: 50)();
  TextColumn get email => text().withLength(min: 5, max: 100).unique()();
  TextColumn get profilePicturePath => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get emergencyContact => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {remoteId};
}
