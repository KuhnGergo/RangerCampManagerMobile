import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_bottom_sheet/chat_options_bottom_sheet.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_screen/chat_screen.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/chat_action_button.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/option_action.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/dialogs/create_room_and_group_dialog.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/dialogs/update_chat_color_dialog.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/text_update_dialog.dart';
import 'package:mastercs_mobile/presentation/components/dialogs/warning_dialog.dart';
import 'package:mastercs_mobile/providers/actions/chat_actions_provider.dart';
import 'package:mastercs_mobile/providers/actions/group_actions_provider.dart';
import 'package:mastercs_mobile/providers/actions/room_actions_provider.dart';
import 'package:mastercs_mobile/utils/validators.dart';

/// Centralized handler for all chat-related actions
/// Provides reusable methods for opening chats, showing dialogs, and handling chat operations
class ChatActionsHandler {
  /// Opens a chat screen
  void openChat(BuildContext context, Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)),
    );
  }

  /// Shows the chat options bottom sheet
  void showBottomSheet(
    BuildContext context,
    WidgetRef ref,
    Chat chat, {
    bool selected = false,
  }) {
    final chatType = ChatType.fromString(chat.type);

    showChatOptionsBottomSheet(
      context,
      ChatOptionsBottomSheet(
        chat: chat,
        actionRef: ref,
        sourceContext: context,
        primaryActionWidgets: _getPrimaryActions(
          context,
          ref,
          chat,
          chatType,
          selected,
        ),
        secondaryActionWidgets: _getSecondaryActions(
          context,
          ref,
          chat,
          chatType,
        ),
        hasJoinCode: chat.joinCode != null,
      ),
    );
  }

  /// Returns primary action widgets based on chat type and selected state
  List<ChatActionButton> _getPrimaryActions(
    BuildContext context,
    WidgetRef ref,
    Chat chat,
    ChatType chatType,
    bool selected,
  ) {
    // Only show primary actions for room/group when selected
    if (!selected) return [];

    final isGroup = chatType == ChatType.group;
    final isRoom = chatType == ChatType.room;

    if (!isGroup && !isRoom) return [];

    final actions = <ChatActionButton>[];

    // Create action
    actions.add(
      ChatActionButton(
        onPressed: () {
          Navigator.pop(context);
          showCreateDialog(context, isGroup: isGroup);
        },
        icon: Icons.add,
        label: 'Create',
      ),
    );

    // Switch action
    actions.add(
      ChatActionButton(
        onPressed: () {
          Navigator.pop(context);
          showJoinDialog(context, ref, isGroup: isGroup);
        },
        icon: Icons.swap_horiz,
        label: 'Switch',
      ),
    );

    actions.add(
      ChatActionButton(
        onPressed: () {
          Navigator.pop(context);
          handleLeave(
            context,
            ref,
            isGroup: chatType == ChatType.group,
            chatId: chat.remoteId,
          );
        },
        icon: Icons.exit_to_app,
        label: 'Leave',
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );

    if (isGroup) {
      actions.add(
        ChatActionButton(
          onPressed: () {
            Navigator.pop(context);
            handleEndGroup(context, ref, chat: chat);
          },
          icon: Icons.stop_circle,
          label: 'End',
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        ),
      );
    }

    return actions;
  }

  /// Returns secondary action widgets based on chat type
  List<Widget> _getSecondaryActions(
    BuildContext context,
    WidgetRef ref,
    Chat chat,
    ChatType chatType,
  ) {
    final actions = <Widget>[];

    switch (chatType) {
      case ChatType.camp:
        break;

      case ChatType.staff:
        break;

      case ChatType.room:
      case ChatType.group:
        actions.add(
          OptionAction(
            onPressed: () {
              Navigator.pop(context);
              handleRenameChat(
                context,
                ref,
                chat,
                isGroup: chatType == ChatType.group,
              );
            },
            icon: Icons.edit,
            label: 'Rename',
          ),
        );
        actions.add(
          OptionAction(
            onPressed: () {
              Navigator.pop(context);
              showColorsDialog(
                context,
                ref,
                chat,
                isGroup: chatType == ChatType.group,
              );
            },
            icon: Icons.palette,
            label: 'Change Color',
          ),
        );
        actions.add(
          OptionAction(
            onPressed: () {
              Navigator.pop(context);
              showUpdateJoinCodeDialog(context, ref, chat: chat);
            },
            icon: Icons.vpn_key,
            label: 'Update Join Code',
          ),
        );
        break;

      case ChatType.archivedRoom:
      case ChatType.archivedGroup:
      case ChatType.archived:
        actions.add(
          OptionAction(
            onPressed: () {
              Navigator.pop(context);
              handleLeave(
                context,
                ref,
                isGroup: chatType == ChatType.archivedGroup,
                chatId: chat.remoteId,
              );
            },
            icon: Icons.exit_to_app,
            label: 'Leave',
            color: Theme.of(context).colorScheme.error,
          ),
        );
        break;

      default:
        break;
    }

    return actions;
  }

  /// Handles renaming a chat
  Future<void> handleRenameChat(
    BuildContext context,
    WidgetRef ref,
    Chat chat, {
    required bool isGroup,
  }) async {
    if (chat.typeId == null) {
      showError(context, 'Chat ID is null');
      return;
    }
    showTextUpdateDialog(
      context: context,
      title: 'Rename ${isGroup ? 'Group' : 'Room'}',
      label: '${isGroup ? 'Group' : 'Room'} Name',
      initialValue: chat.name,
      validator: (String? value) => Validators.chatName(value),
      genericErrorMessage: 'Failed to rename ${isGroup ? 'group' : 'room'}',
      confirmAction: (newName) => isGroup
          ? ref
                .read(groupActionsProvider.notifier)
                .updateGroup(groupId: chat.typeId!, name: newName)
          : ref
                .read(roomActionsProvider.notifier)
                .updateRoom(roomId: chat.typeId!, name: newName),
      maxLength: 50,
    );
  }

  /// Shows join dialog for room or group
  Future<void> showJoinDialog(
    BuildContext context,
    WidgetRef ref, {
    required bool isGroup,
  }) async {
    showTextUpdateDialog(
      context: context,
      errorContext: context,
      title: isGroup ? 'Join Group' : 'Join Room',
      label: 'Join Code',
      hintText: 'Enter join code',
      maxLength: 12,
      validator: (value) => Validators.joinCode(value),
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      confirmAction: (newCode) => isGroup
          ? ref.read(groupActionsProvider.notifier).join(code: newCode)
          : ref.read(roomActionsProvider.notifier).join(code: newCode),
      notFoundMessage: 'No ${isGroup ? 'Group' : 'Room'} with this join code.',
      genericErrorMessage: 'Failed to join ${isGroup ? 'group' : 'room'}',
    );
  }

  /// Shows update join code dialog for room or group
  Future<void> showUpdateJoinCodeDialog(
    BuildContext context,
    WidgetRef ref, {
    required Chat chat,
  }) async {
    if (chat.typeId == null) {
      showError(context, 'Chat ID is null');
      return;
    }
    showTextUpdateDialog(
      context: context,
      errorContext: context,
      title: 'Update Join Code',
      label: 'Join Code',
      initialValue: chat.joinCode ?? '',
      hintText: 'Enter new join code',
      maxLength: 12,
      validator: (value) => Validators.joinCode(value),
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      enableSuggestions: false,
      genericErrorMessage: 'Failed to update join code',
      confirmAction: (newCode) => updateJoinCode(
        context: context,
        ref: ref,
        chat: chat,
        newCode: newCode,
      ),
      badRequestMessage: 'Join code already in use.',
    );
  }

  // Updates join code for room or group
  Future<void> updateJoinCode({
    required BuildContext context,
    required WidgetRef ref,
    required Chat chat,
    required String newCode,
  }) async {
    final isGroup = chat.type == ChatType.group.toString();
    final isRoom = chat.type == ChatType.room.toString();

    if (chat.typeId == null) {
      showError(context, 'Chat ID is null');
      return;
    }

    if (isGroup) {
      await ref
          .read(groupActionsProvider.notifier)
          .updateGroup(groupId: chat.typeId!, joinCode: newCode);
    } else if (isRoom) {
      await ref
          .read(roomActionsProvider.notifier)
          .updateRoom(roomId: chat.typeId!, joinCode: newCode);
    }
  }

  /// Shows create dialog for room or group
  Future<void> showCreateDialog(
    BuildContext context, {
    required bool isGroup,
  }) async {
    return showCreateRoomAndGroupDialog(context: context, isGroup: isGroup);
  }

  /// Handles leaving a room or group
  Future<void> handleLeave(
    BuildContext context,
    WidgetRef ref, {
    required bool isGroup,
    required String chatId,
  }) async {
    showWarningDialog(
      context: context,
      title: 'Leave ${isGroup ? 'Group' : 'Room'}?',
      secondThoughtLabel: 'You will need a join code to rejoin.',
      message:
          'Are you sure you want to leave this ${isGroup ? 'group' : 'room'}?',
      confirmLabel: 'Leave',
      cancelLabel: 'Cancel',
      genericErrorMessage: 'Failed to leave ${isGroup ? 'group' : 'room'}',
      confirmAction: () async {
        if (isGroup) {
          await ref.read(groupActionsProvider.notifier).leave();
        } else {
          await ref.read(roomActionsProvider.notifier).leave();
        }
      },
    );
  }

  Future<void> handleEndGroup(
    BuildContext context,
    WidgetRef ref, {
    required Chat chat,
  }) async {
    showWarningDialog(
      context: context,
      title: 'End Group?',
      secondThoughtLabel: 'This will archive the group for all members.',
      message: 'Are you sure you want to end this group?',
      confirmLabel: 'End',
      cancelLabel: 'Cancel',
      genericErrorMessage: 'Failed to end group',
      confirmAction: () async {
        await ref.read(chatActionsProvider.notifier).endGroup(chat);
      },
    );
  }

  /// Shows the color change dialog for recoloring a chat
  Future<void> showColorsDialog(
    BuildContext context,
    WidgetRef ref,
    Chat chat, {
    required bool isGroup,
  }) async {
    return showUpdateColorDialog(
      context: context,
      errorContext: null,
      chat: chat,
    );
  }
}
