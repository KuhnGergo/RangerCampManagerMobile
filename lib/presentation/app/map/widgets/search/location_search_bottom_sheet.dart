import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/app/map/map_controller.dart';
import 'package:mastercs_mobile/presentation/components/member/member_info_item.dart';
import 'package:mastercs_mobile/presentation/components/user_profile/user_profile_screen.dart';
import 'package:mastercs_mobile/providers/location/filtered_members_with_location_provider.dart';

/// Extended list with search functionality shown in a bottom sheet
class MapExtendedList extends ConsumerStatefulWidget {
  const MapExtendedList({super.key});

  @override
  ConsumerState<MapExtendedList> createState() => _MapExtendedListState();
}

class _MapExtendedListState extends ConsumerState<MapExtendedList>
    with WidgetsBindingObserver {
  final _controller = DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  double _keyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final viewInsets =
        WidgetsBinding.instance.platformDispatcher.views.first.viewInsets;

    final newHeight = viewInsets.bottom;

    if (newHeight != _keyboardHeight) {
      _keyboardHeight = newHeight;

      if (_keyboardHeight > 0) {
        _controller.animateTo(
          0.95,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeIn,
        );
      }
    }
  }

  void _focusOnMember(Member member) {
    ref.read(mapControllerProvider.notifier).setFollowedMember(member);

    final position = member.position;
    if (position == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userId: member.userRemoteId),
        ),
      );
      return;
    }

    final mapController = ref.read(mapControllerProvider.notifier);
    mapController.animateToPosition(position);

    // Close the bottom sheet
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),

      child: DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: keyboardVisible ? 0.95 : 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.95,
        expand: false,
        snap: true,
        snapSizes: const [0.95],
        builder: (context, scrollController) => Material(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Column(
            children: [
              // Drag bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with back button and search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),

                    const SizedBox(width: 8),

                    // Search bar
                    Expanded(
                      child: TextField(
                        maxLines: 1,
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search members...',
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : const Icon(Icons.search),
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Members list
              Expanded(
                child: ref
                    .watch(filteredMembersWithLocationProvider)
                    .when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: colorScheme.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load members',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (allMembers) {
                        final searchText = _searchController.text
                            .toLowerCase()
                            .trim();
                        final members = searchText.isEmpty
                            ? allMembers
                            : allMembers
                                  .where(
                                    (m) => m.name.toLowerCase().contains(
                                      searchText,
                                    ),
                                  )
                                  .toList();

                        if (members.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_search,
                                    size: 64,
                                    color: colorScheme.onSurface.withAlpha(100),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    searchText.isEmpty
                                        ? 'No members found'
                                        : 'No results for "${_searchController.text}"',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withAlpha(150),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            bottom: 16.0,
                          ),
                          child: ListView.separated(
                            controller: scrollController,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: members.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final member = members[index];
                              return MemberInfoItem(
                                member: member,
                                onTap: () => _focusOnMember(member),
                                backgroundColor: colorScheme.surface,
                                locationFocus: true,
                                showGroup: true,
                                showRole: true,
                                showRoom: false,
                                showDistance: false,
                              );
                            },
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
