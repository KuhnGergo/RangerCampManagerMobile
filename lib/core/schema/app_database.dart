import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables/member_to_chat_table.dart';
import 'tables/camps_table.dart';
import 'tables/chats_table.dart';
import 'tables/locations_table.dart';
import 'tables/member_to_camp_table.dart';
import 'tables/messages_table.dart';
import 'tables/payments_table.dart';
import 'tables/user_payments_table.dart';
import 'tables/users_table.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/user_dao.dart';
import '../../data/db/camp_dao.dart';

part 'app_database.g.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

@DriftDatabase(
  tables: [
    Users,
    Locations,
    Payments,
    UserPayments,
    Camps,
    Chats,
    MemberToCamp,
    MemberToChat,
    Messages,
  ],
  daos: [UserDao, CampDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._();

  // ! Ha változik az adatbázis sémája, növeld ezt a számot, különben hiba lesz!
  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      await m.deleteTable('users');
      await m.deleteTable('locations');
      await m.deleteTable('payments');
      await m.deleteTable('user_payments');
      await m.deleteTable('camps');
      await m.deleteTable('chat_members');
      await m.deleteTable('chats');
      await m.deleteTable('member_to_camp');
      await m.deleteTable('member_to_chat');
      await m.deleteTable('messages');
      await m.createAll();
    },
  );

  Future<void> clearDatabase() async {
    await delete(users).go();
    await delete(locations).go();
    await delete(payments).go();
    await delete(userPayments).go();
    await delete(camps).go();
    await delete(chats).go();
    await delete(memberToCamp).go();
    await delete(memberToChat).go();
    await delete(messages).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}
