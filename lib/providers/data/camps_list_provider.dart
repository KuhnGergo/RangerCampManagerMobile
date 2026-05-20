import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/db/camp_dao.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';

/// Provider for getting all available camps
final campsListProvider = StreamProvider.autoDispose<List<Camp>>((ref) {
  return ref.read(campDaoProvider).watchCamps();
});
