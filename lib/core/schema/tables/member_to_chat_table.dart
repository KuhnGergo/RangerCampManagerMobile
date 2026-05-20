import 'package:drift/drift.dart';

class MemberToChat extends Table {
  TextColumn get userRemoteId => text()();
  TextColumn get chatRemoteId => text()();
  DateTimeColumn get lastViewed => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userRemoteId, chatRemoteId};
}
