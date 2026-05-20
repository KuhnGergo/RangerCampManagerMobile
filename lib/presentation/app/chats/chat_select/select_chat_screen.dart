import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/widgets/chat_list.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/filter_bar/chat_filter_bar.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/chats_no_connection_banner.dart';
import 'package:mastercs_mobile/providers/actions/chat_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/providers/socket/socket_event_providers.dart';

class SelectChatScreen extends ConsumerWidget {
  const SelectChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If the backend tells us we've lost access to a chat, refresh the chat list.
    ref.listen(socketErrorProvider, (_, next) {
      next.whenData((error) {
        if (error.code.toLowerCase() != 'forbidden') return;
        final campId = ref.read(selectedCampIdProvider).value;
        if (campId == null) return;
        unawaited(ref.read(chatActionsProvider.notifier).refreshChats(campId));
      });
    });

    return SafeArea(
      child: Column(
        children: [
          const ChatFilterBar(),
          const ChatsNoConnectionBanner(),
          const Expanded(child: ChatList()),
        ],
      ),
    );
  }
}
