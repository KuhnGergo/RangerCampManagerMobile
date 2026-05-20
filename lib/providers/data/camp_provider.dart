import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/db/camp_dao.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';

final campProvider = StreamProvider.autoDispose<Camp?>((ref) {
  final campIdAsync = ref.watch(selectedCampIdProvider);

  final campId = campIdAsync.maybeWhen(data: (id) => id, orElse: () => null);

  if (campId == null) {
    return Stream.value(null);
  }

  return ref.read(campDaoProvider).watchCamp(campId);
});
