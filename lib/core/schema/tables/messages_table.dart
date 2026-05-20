import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

enum MessageStatus {
  sending, // Message is being sent to server
  sent, // Message sent to server but not confirmed delivered
  arrived, // Message confirmed delivered by server
  error, // Error occurred while sending
}

class Messages extends Table {
  TextColumn get id =>
      text().clientDefault(() => const Uuid().v4())(); // used by Drift
  TextColumn get remoteId => text().nullable()(); // used by API

  TextColumn get chatRemoteId => text()();
  TextColumn get userRemoteId => text()();
  TextColumn get bodyJson => text()(); // JSONB from server

  DateTimeColumn get createdAt => dateTime().nullable()();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  // Message delivery status for own messages
  IntColumn get messageStatus => intEnum<MessageStatus>().withDefault(
    Constant(MessageStatus.sending.index),
  )();

  @override
  Set<Column> get primaryKey => {id};
}
