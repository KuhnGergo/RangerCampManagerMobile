import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/components/member_search/member_search_controller.dart';
import 'package:mastercs_mobile/presentation/components/member_search/search_bar.dart';
import 'package:mastercs_mobile/presentation/components/member/member_info_item.dart';

const String memberSearchHeroTag = 'member-search-hero';

class MemberSearchScreen extends ConsumerWidget {
  const MemberSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(memberSearchControllerProvider.notifier);
    final state = ref.watch(memberSearchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        titleSpacing: 0,
        title: Hero(
          tag: memberSearchHeroTag,
          child: Material(
            type: MaterialType.transparency,
            child: MemberSearchBar(
              initialQuery: state.searchQuery,
              onChanged: controller.updateSearchQuery,
              onClear: controller.clearSearch,
              autofocus: true,
            ),
          ),
        ),
        actions: const [SizedBox(width: 8)],
      ),

      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, MemberSearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return _buildErrorState(context, state.error!);
    }

    if (state.allMembers.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.people_outline,
        title: 'No Members',
        message: 'There are no members in this camp yet.',
      );
    }

    if (state.filteredMembers.isEmpty && state.searchQuery.isNotEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.search_off,
        title: 'No members found',
        message: 'Try adjusting your search query.',
      );
    }

    return _buildMemberList(context, state.filteredMembers);
  }

  Widget _buildMemberList(BuildContext context, List<Member> members) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: members.length,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = members[index];
        return MemberInfoItem(
          member: member,
          showRole: true,
          showGroup: true,
          showRoom: true,
          showDistance: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: colorScheme.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error Loading Members',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
