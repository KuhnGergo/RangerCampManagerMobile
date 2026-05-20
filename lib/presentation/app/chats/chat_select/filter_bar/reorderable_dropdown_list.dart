import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/chats/chat_select/provider/chat_filter_provider.dart';

class ReorderableDropdownList extends ConsumerWidget {
  const ReorderableDropdownList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final filterState = ref.watch(chatFilterProvider);
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: filterState.orderBy.length,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        final List<OrderSubject> newOrder = List.from(filterState.orderBy);
        final item = newOrder.removeAt(oldIndex);
        newOrder.insert(newIndex, item);

        ref.read(chatFilterProvider.notifier).setOrderBy(newOrder);
      },
      itemBuilder: (context, index) {
        final subject = filterState.orderBy[index];
        return Container(
          key: ValueKey(subject),
          decoration: BoxDecoration(
            border: index < filterState.orderBy.length - 1
                ? Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withAlpha(128),
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: ReorderableDragStartListener(
            index: index,
            child: ListTile(
              dense: true,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: index == 0
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(subject.getIcon, size: 20, color: colorScheme.onSurface),
                ],
              ),
              title: Text(
                subject.getLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: index == 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: Icon(
                Icons.drag_handle,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}
