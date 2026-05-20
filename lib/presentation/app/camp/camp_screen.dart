import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_data/camp_overview.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_members/camp_members_overview.dart';
import 'package:mastercs_mobile/presentation/components/widgets/offline_indicator.dart';
import 'package:mastercs_mobile/presentation/components/widgets/pull_to_refresh.dart';
import 'package:mastercs_mobile/providers/actions/camp_actions_provider.dart';

class CampScreen extends ConsumerStatefulWidget {
  final VoidCallback onDeselectCamp;

  const CampScreen({super.key, required this.onDeselectCamp});

  @override
  ConsumerState<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends ConsumerState<CampScreen> {
  final _refreshController = PullToRefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            const OfflineIndicator(),

            Expanded(
              child: PullToRefresh(
                controller: _refreshController,
                minVisibleOffset: 60,
                dragFactor: 0.2,
                onRefresh: () async {
                  try {
                    await ref.read(campActionsProvider.notifier).getFullCamp();
                  } finally {
                    _refreshController.completeRefresh();
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Camp Overview (dates, join code, buttons)
                      CampOverview(onDeselectCamp: widget.onDeselectCamp),

                      // Camp Members Overview (staff, campers, pending)
                      CampMembersOverview(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
