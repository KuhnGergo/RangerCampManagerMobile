import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/data/db/messages_dao.dart';
import 'package:mastercs_mobile/models/chat_message.dart';

/// Provider that watches the last message for a specific chat
/// Returns null if there are no messages in the chat
final lastMessageProvider = StreamProvider.autoDispose
    .family<ChatMessage?, String>((ref, chatId) {
      final dao = ref.watch(messagesDaoProvider);
      return dao.watchLastMessageByChat(chatId).map((message) {
        if (message == null) return null;
        return ChatMessage.fromDriftMessage(message);
      });
    });
