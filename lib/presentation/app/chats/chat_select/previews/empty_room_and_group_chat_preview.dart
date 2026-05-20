import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/widgets/chat_circle.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_actions_handler.dart';

class EmptyRoomAndGroupChatPreview extends ConsumerWidget {
  final ChatType chatType;
  final ChatActionsHandler actionsHandler;

  const EmptyRoomAndGroupChatPreview({
    super.key,
    required this.chatType,
    required this.actionsHandler,
  });

  bool get isGroup => chatType == ChatType.emptyGroup;

  String get _label => isGroup ? 'No Group' : 'No Room';

  String get _description => isGroup
      ? 'Join a group to participate in activities.'
      : 'Join a room to connect with others.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Room header with color indicator
          Ink(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(51),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(16)),

              onTap: () {
                actionsHandler.showJoinDialog(context, ref, isGroup: isGroup);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ChatCircle(type: chatType, size: 60, highlighted: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _label,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                          Text(
                            _description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.login, color: colorScheme.onSurface),
                    ),

                    IconButton(
                      onPressed: () => actionsHandler.showCreateDialog(
                        context,
                        isGroup: isGroup,
                      ),
                      icon: Icon(Icons.add, color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
