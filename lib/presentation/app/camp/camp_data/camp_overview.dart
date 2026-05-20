import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_data/widgets/date_range.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_data/widgets/deselect_camp_button.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_data/widgets/manage_camp_button.dart';
import 'package:mastercs_mobile/presentation/app/camp/camp_data/widgets/min_group_size_card.dart';
import 'package:mastercs_mobile/presentation/components/join_code/join_code_card.dart';
import 'package:mastercs_mobile/presentation/components/join_code/show_qr_code_button.dart';
import 'package:mastercs_mobile/providers/data/camp_provider.dart';

class CampOverview extends ConsumerWidget {
  final VoidCallback onDeselectCamp;

  const CampOverview({super.key, required this.onDeselectCamp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campAsync = ref.watch(campProvider);

    return campAsync.when(
      data: (camp) {
        if (camp == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No camp selected',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: DeselectCampButton(
                      deselectedCallback: onDeselectCamp,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: ManageCampButton()),
                ],
              ),
              SizedBox(height: 16),

              // Date Range Widget
              if (camp.startDate != null && camp.endDate != null)
                DateRange(startDate: camp.startDate!, endDate: camp.endDate!),
              SizedBox(height: 8),

              MinGroupSizeCard(minGroupSize: camp.minGroupSize),
              SizedBox(height: 16),

              // Join Code Card
              if (camp.joinCode != null) ...[
                JoinCodeCard(
                  joinCode: camp.joinCode!,
                  hasCopyAction: true,
                  hasChangeAction: false,
                ),
                SizedBox(height: 8),
                ShowQRCodeButton(campId: camp.remoteId),
              ],
            ],
          ),
        );
      },
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Error loading camp: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}
