import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/db/user_dao.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';

final accountProvider = StreamProvider.autoDispose<User?>((ref) {
  final userId = ref.watch(authProvider.notifier).getUserId;

  if (userId == null) {
    return const Stream.empty();
  }

  return ref.read(userDaoProvider).watchUser(userId);
});
