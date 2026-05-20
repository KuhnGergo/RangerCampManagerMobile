import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_message.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_actions_handler.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/previews/empty_room_and_group_chat_preview.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/previews/room_and_group_chat_preview.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/previews/empty_chat_preview.dart';
import 'package:mastercs_mobile/providers/data/group_provider.dart';
import 'package:mastercs_mobile/providers/data/room_provider.dart';
import 'chat_preview.dart';

class ChatPreviewFactory {
  final ChatActionsHandler actionsHandler = ChatActionsHandler();

  Widget createChatPreview({
    required Chat chat,
    bool highlighted = false,
    ChatMessage? lastMessage,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final chatType = ChatType.fromString(chat.type);

    bool isSelectedRoom =
        ref.read(roomProvider).value?.remoteId == chat.remoteId || false;
    bool isSelectedGroup =
        ref.read(groupProvider).value?.remoteId == chat.remoteId || false;

    switch (chatType) {
      case ChatType.camp:
      case ChatType.staff:
        return ChatPreview(
          chat: chat,
          highlighted: true,
          lastMessage: lastMessage,
          onTap: () => actionsHandler.openChat(context, chat),
          onLongPress: () => actionsHandler.showBottomSheet(context, ref, chat),
        );
      case ChatType.room:
      case ChatType.group:
        if (isSelectedRoom || isSelectedGroup) {
          return RoomAndGroupChatPreview(
            chat: chat,
            lastMessage: lastMessage,
            actionsHandler: actionsHandler,
          );
        }
        return ChatPreview(
          chat: chat,
          highlighted: true,
          lastMessage: lastMessage,
          onTap: () => actionsHandler.openChat(context, chat),
          onLongPress: () => actionsHandler.showBottomSheet(context, ref, chat),
        );
      case ChatType.emptyCamp:
      case ChatType.emptyStaff:
        return EmptyChatPreview(chatType: chatType);
      case ChatType.emptyRoom:
      case ChatType.emptyGroup:
        return EmptyRoomAndGroupChatPreview(
          chatType: chatType,
          actionsHandler: actionsHandler,
        );
      default:
        return ChatPreview(
          chat: chat,
          highlighted: false,
          lastMessage: lastMessage,
          onTap: () => actionsHandler.openChat(context, chat),
          onLongPress: () => actionsHandler.showBottomSheet(context, ref, chat),
        );
    }
  }
}
