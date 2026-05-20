import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_actions_handler.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/error/app_snackbar.dart';
import 'package:mastercs_mobile/providers/actions/chat_actions_provider.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_screen/widgets/messages_list.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_screen/widgets/send_message_bar.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_screen/widgets/typing_indicator.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/widgets/chat_circle.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/chats_no_connection_banner.dart';
import 'package:mastercs_mobile/providers/data/chat_info_message_provider.dart';
import 'package:mastercs_mobile/providers/data/chat_members_family_provider.dart';
import 'package:mastercs_mobile/providers/data/member_to_chat_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/providers/socket/socket_event_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Chat chat;
  const ChatScreen({super.key, required this.chat});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  bool _handledForbidden = false;
  bool _didForceExitRefresh = false;

  Future<void> _forceViewChatRefresh() async {
    if (_didForceExitRefresh) return;
    _didForceExitRefresh = true;

    final chatId = widget.chat.remoteId;
    if (chatId.isEmpty) return;

    try {
      await ref.read(chatActionsProvider.notifier).viewChat(chatId);
    } catch (_) {
      // Best-effort on exit.
    }

    ref.invalidate(memberToChatProvider(chatId));
    ref.invalidate(chatMembersViewProvider(chatId));
  }

  Future<void> _handleBackNavigation(BuildContext context) async {
    await _forceViewChatRefresh();
    if (!mounted && !context.mounted) return;
    Navigator.of(context).pop();
  }

  void _handleSendMessage(
    String messageText,
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      final controller = ref.read(chatActionsProvider.notifier);
      await controller.sendTextMessage(
        chatId: widget.chat.remoteId,
        text: messageText,
      );
    } catch (e) {
      if (context.mounted) {
        showError(
          context,
          'Failed to send message.',
          extendedText: e.toString(),
        );
      }
    }
  }

  void _showChatOptions(BuildContext context, WidgetRef ref) {
    final actionsHandler = ChatActionsHandler();
    actionsHandler.showBottomSheet(context, ref, widget.chat);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Mark chat as viewed when user enters.
      ref.read(chatActionsProvider.notifier).viewChat(widget.chat.remoteId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Handle "FORBIDDEN" socket errors (lost chat access)
    ref.listen(socketErrorProvider, (_, next) {
      next.whenData((error) {
        if (_handledForbidden) return;
        if (error.code.toLowerCase() != 'forbidden') return;

        _handledForbidden = true;

        final campId = ref.read(selectedCampIdProvider).value;
        if (campId != null) {
          // Best-effort refresh so the chat list updates.
          unawaited(
            ref.read(chatActionsProvider.notifier).refreshChats(campId),
          );
        }

        if (!mounted) return;
        if (context.mounted) {
          showError(
            context,
            'You no longer have access to this chat.',
            extendedText:
                'It may have been deleted or your permissions may have changed.',
          );

          Navigator.of(context).pop();
        }
      });
    });

    ref.listen(chatInfoMessageProvider, (_, next) {
      next.whenData((infoMessage) {
        if (infoMessage.chatRemoteId != widget.chat.remoteId) {
          return;
        }
        if (!mounted || !context.mounted) return;
        showInfoSnackbar(context, infoMessage.message);
      });
    });

    return WillPopScope(
      onWillPop: () async {
        await _forceViewChatRefresh();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: colorScheme.surface,
          centerTitle: true,
          leadingWidth: 100,
          leading: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBackNavigation(context),
              ),
              ChatCircle(
                type: ChatType.fromString(widget.chat.type),
                textColor: widget.chat.color,
                size: 36,
              ),
            ],
          ),
          title: Text(
            widget.chat.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showChatOptions(context, ref),
              tooltip: 'Chat options',
            ),
          ],
        ),
        body: Column(
          children: [
            const ChatsNoConnectionBanner(),
            // Messages area
            Expanded(child: MessagesList(chat: widget.chat)),

            // Typing indicator
            TypingIndicator(chatId: widget.chat.remoteId),

            // Send message bar
            SendMessageBar(
              chatId: widget.chat.remoteId,
              chatColor: widget.chat.color,
              enabled: true,
              onSend: (message) => _handleSendMessage(message, ref, context),
            ),
          ],
        ),
      ),
    );
  }
}
