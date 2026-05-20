import 'package:drift/drift.dart';

class Chats extends Table {
  TextColumn get remoteId => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get color => text().nullable()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  TextColumn get campRemoteId => text()();

  /// 'Real Room Id', 'Real Group Id', 'Archived Chat Has no typeId', 'Camp Id'
  TextColumn get typeId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get joinCode => text().nullable()();

  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {remoteId};
}
