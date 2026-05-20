import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/camp_selection/widgets/camp_preview_tile.dart';
import 'package:mastercs_mobile/providers/data/camps_list_provider.dart';

class CampsListView extends ConsumerWidget {
  final Future<void> Function(String)? onCampSelected;
  final String? selectedCampId;

  const CampsListView({super.key, this.onCampSelected, this.selectedCampId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camps = ref.watch(campsListProvider).value ?? [];

    return ListView.builder(
      itemCount: camps.length,
      itemBuilder: (context, index) {
        final camp = camps[index];
        return CampPreviewTile(
          camp: camp,
          isSelected: camp.remoteId == selectedCampId,
          onSelectCamp: onCampSelected,
        );
      },
    );
  }
}
