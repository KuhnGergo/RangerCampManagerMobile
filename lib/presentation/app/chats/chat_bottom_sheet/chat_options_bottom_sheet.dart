import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/chat_types.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_bottom_sheet/chat_members_section.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_bottom_sheet/chat_primary_actions_container.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_actions_handler.dart';
import 'package:mastercs_mobile/presentation/app/chats/utils/chat_color_helper.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/chat_action_button.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/chat_type_tag.dart';
import 'package:mastercs_mobile/presentation/components/join_code/join_code_card.dart';
import 'package:mastercs_mobile/providers/data/camp_role_provider.dart';
import 'package:mastercs_mobile/utils/color_utils.dart';

/// Unified chat options bottom sheet that uses policy-based action resolution
/// This widget stays abstract and only instantiates actions based on chat type and user role
class ChatOptionsBottomSheet extends ConsumerWidget {
  final Chat chat;
  final List<ChatActionButton> primaryActionWidgets;
  final List<Widget> secondaryActionWidgets;
  final bool hasJoinCode;
  final BuildContext sourceContext;
  final WidgetRef actionRef;

  const ChatOptionsBottomSheet({
    super.key,
    required this.chat,
    required this.primaryActionWidgets,
    required this.secondaryActionWidgets,
    required this.hasJoinCode,
    required this.sourceContext,
    required this.actionRef,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final role = ref
        .read(campRoleProvider)
        .maybeWhen(
          data: (roleString) => Role.fromString(roleString ?? 'camper'),
          orElse: () => Role.camper,
        );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag indicator
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withAlpha(0x66),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header with chat name and type
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ChatColorHelper.getBackgroundColor(chat.color),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        chat.name,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ChatTypeTag(
                      type: ChatType.fromString(chat.type),
                      chatColor:
                          chat.color ??
                          ColorUtils.colorToHex(colorScheme.primary),
                    ),

                    // Join Code Card
                    if (chat.joinCode != null && hasJoinCode) ...[
                      const SizedBox(height: 24),
                      JoinCodeCard(
                        joinCode: chat.joinCode!,
                        hasCopyAction: true,
                        hasChangeAction: role.canManageChat(
                          ChatType.fromString(chat.type),
                        ),
                        onChange: (value) =>
                            ChatActionsHandler().updateJoinCode(
                              chat: chat,
                              ref: actionRef,
                              context: sourceContext,
                              newCode: value,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Primary action buttons (create, switch, end)
                    if (primaryActionWidgets.isNotEmpty) ...[
                      ChatPrimaryActionsContainer(
                        actions: primaryActionWidgets,
                        chat: chat,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),

              // Members Section
              ChatMembersSection(chat: chat),

              const SizedBox(height: 12),

              // Actions - instantiated from factory based on resolved actions
              if (secondaryActionWidgets.isEmpty)
                const SizedBox.shrink()
              else
                ...secondaryActionWidgets.map((widget) => widget),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

void showChatOptionsBottomSheet(
  BuildContext context,
  ChatOptionsBottomSheet sheet,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => sheet,
  );
}
