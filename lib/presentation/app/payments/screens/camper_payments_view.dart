import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/payments/payment_inforamtions.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/camper/no_payment_camper_widget.dart';
import 'package:mastercs_mobile/presentation/components/widgets/pull_to_refresh.dart';
import 'package:mastercs_mobile/providers/actions/payment_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/payments_list_provider.dart';
import 'package:mastercs_mobile/providers/data/payments_by_user_provider.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/camper/camper_payment_list_item.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/camper/payment_date_separator.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/camper/camper_currency_carousel.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';

class CamperPaymentsView extends ConsumerWidget {
  const CamperPaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsListProvider);
    final userPaymentsAsync = ref.watch(userPaymentsProvider);
    final userId = ref.read(authProvider.notifier).getUserId;
    final refreshController = PullToRefreshController();

    return PullToRefresh(
      controller: refreshController,
      minVisibleOffset: 40,
      dragFactor: 0.2,
      onRefresh: () async {
        // Trigger a refresh of the payments data
        await ref.read(paymentActionsProvider.notifier).refreshPayments();
        refreshController.completeRefresh();
      },
      child: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (payments) {
          return userPaymentsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
            data: (userPayments) {
              // Get user's payment status
              final myPayments = userPayments[userId] ?? {};

              // Group payments by currency
              final paymentsByCurrency = <String, List<Payment>>{};
              for (final payment in payments) {
                if (!paymentsByCurrency.containsKey(payment.currency)) {
                  paymentsByCurrency[payment.currency] = [];
                }
                paymentsByCurrency[payment.currency]!.add(payment);
              }

              // Calculate totals per currency
              final currencyDataList = paymentsByCurrency.entries.map((entry) {
                final currency = entry.key;
                final currencyPayments = entry.value;

                final paidAmount = currencyPayments
                    .where((p) => myPayments[p.remoteId] == true)
                    .fold<int>(0, (sum, p) => sum + p.amount);

                final upcomingAmount = currencyPayments
                    .where((p) => myPayments[p.remoteId] != true)
                    .fold<int>(0, (sum, p) => sum + p.amount);

                return CamperCurrencyData(
                  currency: currency,
                  paidAmount: paidAmount,
                  upcomingAmount: upcomingAmount,
                );
              }).toList();

              // Sort payments by due date
              final sortedPayments = [...payments]
                ..sort((a, b) {
                  if (a.dueDate == null && b.dueDate == null) return 0;
                  if (a.dueDate == null) return 1;
                  if (b.dueDate == null) return -1;
                  return a.dueDate!.compareTo(b.dueDate!);
                });

              // Group payments by date
              final groupedPayments = <String, List<Payment>>{};
              for (final payment in sortedPayments) {
                final dateKey =
                    payment.dueDate?.toIso8601String().split('T')[0] ??
                    'no-date';
                if (!groupedPayments.containsKey(dateKey)) {
                  groupedPayments[dateKey] = [];
                }
                groupedPayments[dateKey]!.add(payment);
              }

              // Build list items with separators
              final listItems = <Widget>[];
              groupedPayments.forEach((dateKey, paymentsForDate) {
                final date = dateKey != 'no-date'
                    ? DateTime.parse(dateKey)
                    : null;
                listItems.add(PaymentDateSeparator(date: date));
                for (final payment in paymentsForDate) {
                  final isPaid = myPayments[payment.remoteId] == true;
                  listItems.add(
                    CamperPaymentListItem(payment: payment, isPaid: isPaid),
                  );
                }
              });

              return Column(
                children: [
                  CamperCurrencyCarousel(currencyData: currencyDataList),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12,
                    ),
                    child: PaymentInforamtions(),
                  ),
                  Expanded(
                    child: sortedPayments.isEmpty
                        ? NoPaymentCamperWidget()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: listItems.length,
                            itemBuilder: (context, index) {
                              return listItems[index];
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
