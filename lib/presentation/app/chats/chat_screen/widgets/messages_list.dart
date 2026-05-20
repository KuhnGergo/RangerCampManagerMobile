import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/core/schema/tables/messages_table.dart';
import 'package:mastercs_mobile/models/chat_member.dart';

import 'package:mastercs_mobile/presentation/app/chats/chat_screen/widgets/date_info_widget.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_screen/widgets/message_widget.dart';
import 'package:mastercs_mobile/providers/data/account_provider.dart';
import 'package:mastercs_mobile/providers/data/chat_members_family_provider.dart';
import 'package:mastercs_mobile/providers/actions/chat_actions_provider.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_screen/controllers/message_provider.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';

class MessagesList extends ConsumerStatefulWidget {
  final Chat chat;
  const MessagesList({super.key, required this.chat});

  @override
  ConsumerState<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends ConsumerState<MessagesList> {
  String? _tappedMessageId;
  static const _lastSeenGrace = Duration(seconds: 1);

  final _scrollController = ScrollController();
  bool _isAtBottom = true;
  bool _hasUserScrolled = false;
  String? _lastViewChatForMessageId;
  DateTime? _lastViewChatEmitAt;
  String _lastSeenFingerprint = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      _hasUserScrolled = true;
    }

    // ListView is reversed. pixels==0 means we are at the bottom (newest).
    final atBottom = _scrollController.position.pixels <= 24;
    if (atBottom != _isAtBottom) {
      _isAtBottom = atBottom;
      if (_isAtBottom) {
        _emitViewChatThrottled();
      }
    }

    // When user scrolls up (towards older messages), pixels approaches maxScrollExtent.
    final maxExtent = _scrollController.position.maxScrollExtent;
    final nearTop =
        _hasUserScrolled &&
        maxExtent > 0 &&
        _scrollController.position.pixels >= (maxExtent - 12);
    if (nearTop) {
      ref.read(messageProvider(widget.chat.remoteId).notifier).loadOlder();
    }
  }

  void _emitViewChatThrottled({bool force = false}) {
    if (widget.chat.remoteId.isEmpty) return;

    final now = DateTime.now();
    final last = _lastViewChatEmitAt;
    if (!force &&
        last != null &&
        now.difference(last) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastViewChatEmitAt = now;

    ref.read(chatActionsProvider.notifier).viewChat(widget.chat.remoteId);
  }

  String _buildLastSeenFingerprint(List<ChatMember> members) {
    if (members.isEmpty) return '';

    final entries = members.map((m) {
      final viewedAtMs = m.lastViewed?.toUtc().millisecondsSinceEpoch ?? -1;
      return '${m.userRemoteId}|$viewedAtMs';
    }).toList()..sort();

    return entries.join(',');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<AsyncValue<List<ChatMember>>>(
      chatMembersViewProvider(widget.chat.remoteId),
      (_, next) {
        final nextMembers = next.asData?.value;
        if (nextMembers == null) return;

        final nextFingerprint = _buildLastSeenFingerprint(nextMembers);
        if (nextFingerprint == _lastSeenFingerprint) return;

        _lastSeenFingerprint = nextFingerprint;
        if (!mounted) return;
        setState(() {});
      },
    );

    if (widget.chat.remoteId.isEmpty) {
      return Center(
        child: Text(
          'No chat selected',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    final messageState = ref.watch(messageProvider(widget.chat.remoteId));
    final messages = messageState.messages;

    final currentUserId = ref.watch(accountProvider).asData?.value?.remoteId;

    final membersAsync = ref.watch(
      chatMembersViewProvider(widget.chat.remoteId),
    );

    final members = membersAsync.asData?.value ?? [];

    // Compute one "last seen" anchor message per member for deterministic rendering.
    final seenByMessageId = <String, List<String>>{};
    if (currentUserId != null && messages.isNotEmpty && members.isNotEmpty) {
      for (final member in members) {
        if (member.userRemoteId == currentUserId) continue;

        final memberLastViewed = member.lastViewed?.toLocal();
        if (memberLastViewed == null) continue;

        for (final msg in messages) {
          if (msg.userRemoteId != currentUserId) continue;

          final msgCreatedAt = msg.createdAt?.toLocal();
          if (msgCreatedAt == null) continue;

          // Grace period handles tiny server/client timestamp precision differences.
          if (msgCreatedAt.isAfter(memberLastViewed.add(_lastSeenGrace))) {
            continue;
          }

          final msgId = msg.remoteId ?? msg.id;
          seenByMessageId.putIfAbsent(msgId, () => []).add(member.name);
          break;
        }
      }
    }

    // Mark each newly arrived server-confirmed newest message as viewed.
    // Avoid emitting for optimistic temp messages to prevent skipping the real
    // first update when the server-confirmed message replaces a temp one.
    if (_isAtBottom && messages.isNotEmpty) {
      final newestRemoteId = messages.first.remoteId;
      if (newestRemoteId != null &&
          newestRemoteId.isNotEmpty &&
          _lastViewChatForMessageId != newestRemoteId) {
        _lastViewChatForMessageId = newestRemoteId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _emitViewChatThrottled(force: true);
        });
      }
    }

    if (messages.isEmpty) {
      return ListView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        children: [
          const SizedBox(height: 32),
          MessageWidget(
            content: 'No messages found. Start the conversation! 🔥😎',
            senderName: 'Your conscience',
            timestamp: widget.chat.createdAt?.toLocal() ?? DateTime.now(),
            isMe: false,
            canShowTimestampOnTap: false,
            showTimestamp: true,
            isFirstInGroup: true,
            isLastInGroup: true,
            isSeenByOthers: true,
          ),
        ],
      );
    }

    final showLoadingIndicator = messageState.isLoadingMore;
    final showNoMoreIndicator =
        !showLoadingIndicator && messageState.noMore && messages.isNotEmpty;
    final showTailIndicator = showLoadingIndicator || showNoMoreIndicator;
    final itemCount = messages.length + (showTailIndicator ? 1 : 0);

    // Only the newest contiguous combo of current-user messages should carry
    // non-error status badges (sent/arrived/etc.). Error is shown per-message.
    int? latestMyComboOldestIndex;
    if (messages.isNotEmpty && currentUserId != null) {
      final newest = messages.first;
      if (newest.userRemoteId == currentUserId) {
        latestMyComboOldestIndex = 0;
        for (var i = 1; i < messages.length; i++) {
          final newer = messages[i - 1];
          final older = messages[i];
          final bothMine =
              newer.userRemoteId == currentUserId &&
              older.userRemoteId == currentUserId;
          final hasGap = _hasDateGap(
            newer.createdAt?.toLocal(),
            older.createdAt?.toLocal(),
          );
          if (!bothMine || hasGap) break;
          latestMyComboOldestIndex = i;
        }
      }
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Show newest messages at bottom
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (showLoadingIndicator && index == messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: ThreeDotLoadingIndicator(size: 20)),
          );
        }

        if (showNoMoreIndicator && index == messages.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                'No more messages',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        final message = messages[index];
        final messageCreatedAt = message.createdAt?.toLocal();
        final isMe = message.userRemoteId == currentUserId;
        final olderMessage = index < messages.length - 1
            ? messages[index + 1]
            : null;
        final newerMessage = index > 0 ? messages[index - 1] : null;

        final gapWithOlder = _hasDateGap(
          messageCreatedAt,
          olderMessage?.createdAt?.toLocal(),
        );
        final gapWithNewer = _hasDateGap(
          newerMessage?.createdAt?.toLocal(),
          messageCreatedAt,
        );

        // Check if we should show a date indicator
        final showDateIndicator = index == messages.length - 1 || gapWithOlder;

        // Check if this is first/last in a group from the same sender
        final isFirstInGroup =
            !showDateIndicator &&
                olderMessage != null &&
                olderMessage.userRemoteId == message.userRemoteId &&
                !gapWithOlder
            ? false
            : true;

        final isLastInGroup =
            newerMessage != null &&
                newerMessage.userRemoteId == message.userRemoteId &&
                !gapWithNewer
            ? false
            : true;

        // Should show sender name only on first message in group
        final shouldShowSenderName = isFirstInGroup;

        // Get sender info
        String senderName = 'Unknown';
        String? senderUserId;
        String? senderImageFilename;

        if (members.isNotEmpty) {
          final sender = members.firstWhere(
            (m) => m.userRemoteId == message.userRemoteId,
            orElse: () => members.first,
          );
          senderName = sender.name;
          senderUserId = sender.userRemoteId;
          senderImageFilename = sender.profilePicturePath;
        }

        // Seen names are attached only to the newest message each member has read.
        final messageId = message.remoteId ?? message.id;
        final seenByNames = (seenByMessageId[messageId] ?? [])..sort();
        final isSeenByOthers = seenByNames.isNotEmpty;

        final showSeenRow = isMe && seenByNames.isNotEmpty;
        final isErrorStatus = message.messageStatus == MessageStatus.error;
        final isInLatestMyCombo =
            latestMyComboOldestIndex != null &&
            index <= latestMyComboOldestIndex;
        final isNewestMessage = index == 0;
        final showStatusBadge =
            isMe &&
            !showSeenRow &&
            (isErrorStatus || (isInLatestMyCombo && isNewestMessage));
        final showTimestamp = _tappedMessageId == messageId;

        final dateIndicatorTime = messageCreatedAt ?? DateTime.now();

        return Column(
          children: [
            // Date indicator
            if (showDateIndicator) DateInfoWidget(timestamp: dateIndicatorTime),
            // Message widget
            MessageWidget(
              content: message.text,
              senderName: senderName,
              senderUserId: senderUserId,
              senderImageFilename: senderImageFilename,
              timestamp: messageCreatedAt ?? DateTime.now(),
              isMe: isMe,
              meBubbleColor: widget.chat.color,
              messageStatus: showStatusBadge ? message.messageStatus : null,
              isSeenByOthers: isSeenByOthers,
              seenByNames: seenByNames,
              showSeenIndicator: false,
              shouldShowSenderName: shouldShowSenderName,
              showTimestamp: showTimestamp,
              isFirstInGroup: isFirstInGroup,
              isLastInGroup: isLastInGroup,
              canShowTimestampOnTap: !showDateIndicator,
              onTap: showDateIndicator
                  ? null
                  : () {
                      setState(() {
                        if (_tappedMessageId == messageId) {
                          _tappedMessageId = null;
                        } else {
                          _tappedMessageId = messageId;
                        }
                      });
                    },
            ),
            if (showSeenRow)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          seenByNames.join(", "),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  bool _hasDateGap(DateTime? first, DateTime? second) {
    if (first == null || second == null) return false;
    return first.difference(second).inHours.abs() >= 1;
  }
}
