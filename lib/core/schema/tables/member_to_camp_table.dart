import 'package:drift/drift.dart';

class MemberToCamp extends Table {
  TextColumn get userRemoteId => text()();
  TextColumn get campRemoteId => text()();
  TextColumn get role => text()();
  TextColumn get groupId => text().nullable()();
  TextColumn get roomId => text().nullable()();

  @override
  Set<Column> get primaryKey => {userRemoteId, campRemoteId};
}
