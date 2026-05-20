import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/schema/app_database.dart';
import '../../core/schema/tables/camps_table.dart';

part 'camp_dao.g.dart';

final campDaoProvider = Provider<CampDao>(
  (ref) => CampDao(ref.read(databaseProvider)),
);

@DriftAccessor(tables: [Camps])
class CampDao extends DatabaseAccessor<AppDatabase> with _$CampDaoMixin {
  CampDao(super.db);

  CampsCompanion toCompanion({
    required String id,
    required String remoteId,
    required String name,
    DateTime? startDate,
    DateTime? endDate,
    int? minGroupSize,
    String? createdAt,
    String? updatedAt,
  }) {
    return CampsCompanion(
      remoteId: Value(remoteId),
      name: Value(name),
      startDate: Value(startDate),
      endDate: Value(endDate),
      minGroupSize: Value(minGroupSize),
    );
  }

  /// Get camp by remote ID
  Future<Camp?> getCampByRemoteId(String remoteId) {
    return (select(
      camps,
    )..where((c) => c.remoteId.equals(remoteId))).getSingleOrNull();
  }

  /// Get all camps
  Future<List<Camp>> getAllCamps() {
    return select(camps).get();
  }

  /// Add or update camp
  Future<void> upsertCamp(Camp camp) {
    return into(camps).insertOnConflictUpdate(camp);
  }

  /// Add multiple camps
  Future<void> upsertCamps(List<Camp> campList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(camps, campList);
    });
  }

  /// Delete camps not in the provided list of remote IDs
  Future<int> deleteExcept(List<String> remoteIds) {
    return (delete(
      camps,
    )..where((c) => (c.remoteId.isIn(remoteIds)).not())).go();
  }

  /// Delete camp by ID
  Future<int> deleteCamp(String id) {
    return (delete(camps)..where((c) => c.remoteId.equals(id))).go();
  }

  /// Clear all camps
  Future<int> deleteAllCamps() {
    return delete(camps).go();
  }

  Stream<Camp?> watchCamp(String remoteId) {
    return (select(
      camps,
    )..where((c) => c.remoteId.equals(remoteId))).watchSingleOrNull();
  }

  Stream<List<Camp>> watchCamps() {
    return select(camps).watch();
  }
}
