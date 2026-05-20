import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/api_exception.dart';
import 'package:mastercs_mobile/data/db/camp_dao.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/repositories/chat_repository.dart';
import 'package:mastercs_mobile/repositories/member_repository.dart';
import 'package:mastercs_mobile/repositories/payment_repository.dart';

bool isCampAccessRevokedError(Object error) {
  return error is ApiException &&
      (error.statusCode == 403 || error.statusCode == 404);
}

/// If the API returns 403/404 for camp-specific endpoints, the user is no longer
/// part of that camp (kicked/deleted). This resets selection and purges local
/// camp data so the UI can recover.
///
/// Returns true if the error was handled as a camp access revoked case.
Future<bool> handleCampAccessRevokedIfNeeded(
  Ref ref, {
  required Object error,
  required String campId,
}) async {
  if (!isCampAccessRevokedError(error)) return false;

  final selectedCampId = ref.read(selectedCampIdProvider).value;
  if (selectedCampId == campId) {
    await ref.read(selectedCampIdProvider.notifier).deselect();
  }

  // Purge local camp state so lists/providers update immediately.
  await ref.read(campDaoProvider).deleteCamp(campId);
  await ref.read(chatRepositoryProvider).clearCampChatData(campId);
  await ref.read(memberRepositoryProvider).deleteMembersOfCamp(campId);
  await ref.read(paymentRepositoryProvider).deletePaymentsOfCamp(campId);

  return true;
}
