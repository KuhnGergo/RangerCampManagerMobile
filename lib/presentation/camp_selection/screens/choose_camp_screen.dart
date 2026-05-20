import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/models/app_errors.dart';
import 'package:mastercs_mobile/presentation/camp_selection/widgets/add_camp_button.dart';
import 'package:mastercs_mobile/presentation/camp_selection/widgets/camps_list_view.dart';
import 'package:mastercs_mobile/presentation/components/error/app_snackbar.dart';
import 'package:mastercs_mobile/presentation/components/widgets/offline_indicator.dart';
import 'package:mastercs_mobile/presentation/components/widgets/pull_to_refresh.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/presentation/camp_selection/controllers/choose_camp_controller.dart';
import 'package:mastercs_mobile/providers/data/camp_provider.dart';
import 'package:mastercs_mobile/presentation/components/widgets/account_avatar.dart';
import 'package:mastercs_mobile/presentation/components/error/error_snackbar.dart';

/// Screen for choosing a camp when multiple camps are available
class ChooseCampScreen extends ConsumerWidget {
  final Future<void> Function(String campId) onSelectCamp;

  const ChooseCampScreen({super.key, required this.onSelectCamp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camp = ref.watch(campProvider);
    final selectedCampId = camp.value?.remoteId;

    Future<void> onCampSelected(String campId) async {
      try {
        await onSelectCamp(campId);
      } catch (e, st) {
        if (!context.mounted) return;
        if (e is PendingCampJoinRequestError) {
          showInfoSnackbar(
            context,
            'You have a pending join request for this camp. Please wait for the owner to accept it.',
          );
          return;
        }
        showError(
          context,
          'Failed to select camp',
          extendedText: e.toString(),
          stackTrace: st,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AccountAvatar(),
        ),
        title: Text(
          'Choose Camp',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const OfflineIndicator(),
              Expanded(
                child: Stack(
                  children: [
                    PullToRefresh(
                      onRefresh: () async {
                        await ref
                            .read(chooseCampControllerProvider.notifier)
                            .refreshCamps();
                      },
                      dragFactor: 0.2,
                      minVisibleOffset: 60,
                      triggerOffset: 20,
                      child: CampsListView(
                        selectedCampId: selectedCampId,
                        onCampSelected: onCampSelected,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: true,
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.surface.withAlpha(0),
                                Theme.of(context).colorScheme.surface,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const AddCampButton(),
          if (camp.isLoading)
            const IgnorePointer(
              child: Center(child: ThreeDotLoadingIndicator()),
            ),
        ],
      ),
    );
  }
}
