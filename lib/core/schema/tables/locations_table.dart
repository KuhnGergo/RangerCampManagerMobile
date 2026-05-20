import 'package:drift/drift.dart';

class Locations extends Table {
  TextColumn get userRemoteId => text()();

  TextColumn get campRemoteId => text()();
  RealColumn get longitude => real()();
  RealColumn get latitude => real()();

  DateTimeColumn get lastUpdated => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userRemoteId, campRemoteId};
}
