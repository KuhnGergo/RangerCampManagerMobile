import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/payment_detail/payment_info_card.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/payment_detail/payment_progress_bar.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/payment_detail/payment_search_bar.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/payment_detail/unpaid_only_filter_button.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/payment_detail/user_payments_list.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/payment_detail/manage_payment_bottom_sheet.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/presentation/app/payments/provider/payment_detail_data_provider.dart';
import 'package:mastercs_mobile/providers/data/payments_list_provider.dart';

class PaymentDetailScreen extends ConsumerStatefulWidget {
  final Payment initialPayment;

  const PaymentDetailScreen({super.key, required this.initialPayment});

  @override
  ConsumerState<PaymentDetailScreen> createState() =>
      _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends ConsumerState<PaymentDetailScreen> {
  bool _showOnlyUnpaid = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = ref.watch(paymentDetailDataProvider);
    final payment =
        ref
            .watch(paymentsListProvider)
            .whenData(
              (list) => list.firstWhere(
                (p) => p.remoteId == widget.initialPayment.remoteId,
                orElse: () => widget.initialPayment,
              ),
            )
            .value ??
        widget.initialPayment;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          payment.name,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final isDeleted = await showManagePaymentBottomSheet(
                context,
                ref,
                payment: payment,
              );
              if (isDeleted == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: Icon(Icons.settings_rounded, color: colorScheme.onSurface),
            tooltip: 'Manage Payment',
          ),
        ],
      ),
      body: data.isLoading
          ? const Center(child: ThreeDotLoadingIndicator())
          : _buildContent(context, data, payment),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PaymentDetailData data,
    Payment payment,
  ) {
    final paidCount = data.getPaidCount(payment);
    final progress = data.getProgress(payment);
    final filteredMembers = data.getFilteredMembers(
      searchQuery: _searchQuery,
      showOnlyUnpaid: _showOnlyUnpaid,
      payment: payment,
    );

    return Column(
      children: [
        // Payment info card
        PaymentInfoCard(payment: payment),

        // Progress bar
        PaymentProgressBar(
          progress: progress,
          paidCount: paidCount,
          totalCampers: data.totalCampers,
        ),

        const SizedBox(height: 8),

        // Search bar
        PaymentSearchBar(
          searchQuery: _searchQuery,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
          onReset: () {
            setState(() {
              _searchQuery = '';
            });
          },
        ),

        const SizedBox(height: 12),

        // Filter toggle
        UnpaidOnlyFilterButton(
          showOnlyUnpaid: _showOnlyUnpaid,
          onToggle: (value) {
            setState(() {
              _showOnlyUnpaid = value;
            });
          },
        ),

        const SizedBox(height: 8),

        // Members list
        Expanded(
          child: UserPaymentsList(
            filteredMembers: filteredMembers,
            payment: payment,
          ),
        ),
      ],
    );
  }
}
