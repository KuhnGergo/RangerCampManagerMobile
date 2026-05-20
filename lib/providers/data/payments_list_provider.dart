import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/data/db/payment_dao.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

/// Provider that gives a list of plain payments by camp
final paymentsListProvider = StreamProvider<List<Payment>>((ref) {
  final campId = ref
      .watch(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  if (campId == null) {
    return Stream.value([]);
  }

  return ref.read(paymentDaoProvider).watchPaymentsByCamp(campId);
});
