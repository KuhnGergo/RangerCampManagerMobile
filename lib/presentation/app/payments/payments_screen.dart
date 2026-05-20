import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/data/camp_role_provider.dart';
import 'package:mastercs_mobile/presentation/app/payments/screens/camper_payments_view.dart';
import 'package:mastercs_mobile/presentation/app/payments/screens/owner_payments_view.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(campRoleProvider);

    return roleAsync.when(
      data: (role) {
        // Staff role - should never reach here but safeguard
        if (role == 'Staff') {
          return const Center(child: Text('Access denied'));
        }

        // Owner role - full management view
        if (role == 'Owner') {
          return const SafeArea(child: OwnerPaymentsView());
        }

        // Member/Camper role - readonly view
        return const SafeArea(child: CamperPaymentsView());
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading payments')),
    );
  }
}
