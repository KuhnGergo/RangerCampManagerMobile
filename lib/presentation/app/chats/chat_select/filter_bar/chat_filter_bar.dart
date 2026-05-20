import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/provider/chat_filter_provider.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/filter_bar/toggle_filter_button.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/filter_bar/order_by_dropdown_button.dart';

/// A horizontal bar containing all chat filter controls
class ChatFilterBar extends ConsumerWidget {
  const ChatFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(chatFilterProvider);
    final controller = ref.read(chatFilterProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 8),
          const OrderByDropdownButton(),
          const SizedBox(width: 8),
          ToggleFilterButton(
            label: 'Group by Type',
            icon: Icons.category,
            isActive: filterState.groupByType,
            onPressed: controller.toggleGroupByType,
          ),
          const SizedBox(width: 8),
          ToggleFilterButton(
            label: 'Hide Archived',
            icon: Icons.archive,
            isActive: !filterState.showArchived,
            onPressed: controller.toggleShowArchived,
          ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
