import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/repositories/account_repository.dart';
import 'package:mastercs_mobile/repositories/camp_repository.dart';
import 'package:mastercs_mobile/repositories/chat_repository.dart';
import 'package:mastercs_mobile/repositories/member_repository.dart';
import 'package:mastercs_mobile/repositories/message_repository.dart';
import 'package:mastercs_mobile/repositories/payment_repository.dart';
import 'package:mastercs_mobile/providers/data/camp_provider.dart';
import 'package:mastercs_mobile/providers/sync/sync_provider.dart';
import 'package:mastercs_mobile/providers/sync/last_sync_time_provider.dart';

final syncCoordinatorProvider = Provider<void>((ref) {
  // Local state to track if sync is pending (waiting for campId)

  ref.listen<bool>(canSyncProvider, (previous, next) {
    if (previous == false && next == true) {
      ref.read(campRepositoryProvider).refreshCamps();
      ref.read(accountRepositoryProvider).refreshMyAccount();

      final campId = ref.read(campProvider).value?.remoteId;
      if (campId != null) {
        ref.read(memberRepositoryProvider).refreshCampMembers(campId);
        ref.read(paymentRepositoryProvider).refreshPayments(campId);

        unawaited(
          ref.read(chatRepositoryProvider).getMyCampChats(campId).then((chats) {
            ref
                .read(messageRepositoryProvider)
                .getFirstMessagesForAllChats(chats);
          }),
        );

        // Complete sync and update last sync time
        ref.read(lastSyncTimeNotifierProvider.notifier).updateLastSyncTime();
      }
      // If campId is null, pendingSync remains true until campProvider provides it
    }
  });
});
