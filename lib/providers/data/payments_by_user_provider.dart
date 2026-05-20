import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/db/user_payment_dao.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';

/// Provider that gives a map of user payments
/// ```dart
/// Map<userId, Map<paymentId, UserPaymentData>>
/// ```
final userPaymentsProvider = StreamProvider<Map<String, Map<String, bool>>>((
  ref,
) {
  final campId = ref
      .watch(selectedCampIdProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  if (campId == null) {
    return Stream.value({});
  }

  final userPaymentDao = ref.read(userPaymentDaoProvider);

  return userPaymentDao.watchAllUserPaymentsByCamp(campId);
});
