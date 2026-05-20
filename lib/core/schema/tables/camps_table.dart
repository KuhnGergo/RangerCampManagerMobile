import 'package:drift/drift.dart';

class Camps extends Table {
  TextColumn get remoteId => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get minGroupSize => integer().nullable()();

  TextColumn get chatRemoteId => text().nullable()();
  TextColumn get staffChatRemoteId => text()();
  TextColumn get joinCode => text().nullable()();

  TextColumn get myRole => text()();

  @override
  Set<Column> get primaryKey => {remoteId};
}
