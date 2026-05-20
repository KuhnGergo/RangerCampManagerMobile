import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/bottom_member_list/member_location_search_button.dart';
import 'package:mastercs_mobile/presentation/app/map/widgets/bottom_member_list/small_location_member_list_item.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/location/filtered_members_with_location_provider.dart';

/// Quick list showing members with location data at the bottom of the map
class MapQuickList extends ConsumerWidget {
  const MapQuickList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ref
          .watch(filteredMembersWithLocationProvider)
          .when(
            loading: () => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: ThreeDotLoadingIndicator(),
              ),
            ),
            error: (e, st) => const SizedBox.shrink(),
            data: (membersWithLocation) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,

                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount:
                    membersWithLocation.length + 1, // +1 for search button
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // First item is the search button
                    return const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: MemberLocationSearchButton(),
                    );
                  } else {
                    // Rest are member items
                    final member = membersWithLocation[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SmallLocationMemberListItem(member: member),
                    );
                  }
                },
              );
            },
          ),
    );
  }
}
