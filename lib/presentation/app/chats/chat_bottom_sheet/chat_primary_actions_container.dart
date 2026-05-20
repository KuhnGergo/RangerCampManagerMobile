import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/presentation/app/chats/widgets/chat_action_button.dart';

/// Container for primary chat actions (create, join, end)
/// These are displayed as prominent buttons at the top of the bottom sheet
class ChatPrimaryActionsContainer extends StatelessWidget {
  final List<ChatActionButton> actions;
  final Chat chat;

  const ChatPrimaryActionsContainer({
    super.key,
    required this.actions,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final int crossAxisCount;
    if (actions.length == 4) {
      crossAxisCount = 2;
    } else if (actions.length == 3) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = actions.length.clamp(1, 3).toInt();
    }

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 48,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      children: actions,
    );
  }
}
