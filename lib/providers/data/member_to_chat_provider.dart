import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/db/member_to_chat_dao.dart';
import 'package:mastercs_mobile/models/member_to_chat.dart';

/// Provider for simplified member-to-chat data (userId, chatId, lastViewed only)
final memberToChatProvider =
    StreamProvider.family<List<MemberToChatData>, String>((ref, chatId) {
  return ref.read(memberToChatDaoProvider).watchMemberToChatByChat(chatId);
});
