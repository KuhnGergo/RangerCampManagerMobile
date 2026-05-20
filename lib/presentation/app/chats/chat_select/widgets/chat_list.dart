import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_category.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/provider/chat_list_view_provider.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/provider/last_message_provider.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/widgets/error_loading_chats.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/widgets/no_chat_found.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/previews/chat_preview_factory.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/pull_to_refresh.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';
import 'package:mastercs_mobile/providers/actions/chat_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/selected_camp_id_provider.dart';
import 'package:mastercs_mobile/repositories/member_repository.dart';

class ChatList extends ConsumerStatefulWidget {
  const ChatList({super.key});

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final _refreshController = PullToRefreshController();
  final _previousChats = <ChatCategory, List<Chat>>{};

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildChatList(
    BuildContext context,
    Map<ChatCategory, List<Chat>> groupedChats,
    ChatPreviewFactory previewFactory,
  ) {
    if (groupedChats.isEmpty) {
      return const NoChatFound();
    }

    // Filter out empty categories
    final nonEmptyCategories = groupedChats.entries
        .where((entry) => entry.value.isNotEmpty)
        .toList();

    if (nonEmptyCategories.isEmpty) {
      return const NoChatFound();
    }

    return PullToRefresh(
      onRefresh: () async {
        try {
          final campId = ref.read(selectedCampIdProvider).value;
          await ref.read(chatActionsProvider.notifier).refreshChats(campId);
          if (campId != null) {
            await ref.read(memberRepositoryProvider).refreshCampMembers(campId);
          }
        } catch (e) {
          final campId = ref.read(selectedCampIdProvider).value;
          if (campId != null) {
            ref
                .read(campActionsProvider.notifier)
                .handleCampAccessRevoked(error: e, campId: campId);
          }
          if (mounted && context.mounted) {
            showError(
              context,
              'Failed to refresh chat data.',
              extendedText: e.toString(),
            );
          }
        } finally {
          _refreshController.completeRefresh();
        }
      },
      controller: _refreshController,
      dragFactor: 0.2,
      child: ListView.builder(
        itemCount: nonEmptyCategories.fold<int>(
          0,
          (total, entry) => total + entry.value.length + 1, // +1 for header
        ),
        itemBuilder: (context, index) {
          int currentIndex = 0;

          // Find which category and chat this index belongs to
          for (final entry in nonEmptyCategories) {
            final category = entry.key;
            final chats = entry.value;

            // Check if this is the category header
            if (index == currentIndex) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  ChatCategory.getLabel(category),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }

            currentIndex++;

            // Check if this is one of the chats in this category
            if (index < currentIndex + chats.length) {
              final chatIndex = index - currentIndex;
              final chat = chats[chatIndex];
              final lastMessageAsync = ref.watch(
                lastMessageProvider(chat.remoteId),
              );

              return lastMessageAsync.when(
                data: (lastMessage) {
                  return previewFactory.createChatPreview(
                    context: context,
                    chat: chat,
                    lastMessage: lastMessage,
                    ref: ref,
                  );
                },
                loading: () => previewFactory.createChatPreview(
                  context: context,
                  chat: chat,
                  lastMessage: null,
                  ref: ref,
                ),
                error: (_, __) => previewFactory.createChatPreview(
                  context: context,
                  ref: ref,
                  chat: chat,
                  lastMessage: null,
                ),
              );
            }

            currentIndex += chats.length;
          }

          // Should never reach here
          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListViewProvider);
    final previewFactory = ChatPreviewFactory();

    return chatsAsync.when(
      data: (groupedChats) {
        // Cache the current chats to prevent throttling on refresh
        _previousChats.clear();
        _previousChats.addAll(groupedChats);

        return _buildChatList(context, groupedChats, previewFactory);
      },
      loading: () {
        // Show previous chats if available during refresh, otherwise show loading
        if (_previousChats.isNotEmpty) {
          return _buildChatList(context, _previousChats, previewFactory);
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const SizedBox(
            height: 80,
            child: Center(child: ThreeDotLoadingIndicator()),
          ),
        );
      },
      error: (error, _) => ErrorLoadingChats(error: error),
    );
  }
}
