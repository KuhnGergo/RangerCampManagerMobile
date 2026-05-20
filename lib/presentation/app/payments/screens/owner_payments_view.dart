import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/owner/no_payment_widget.dart';
import 'package:mastercs_mobile/presentation/components/widgets/pull_to_refresh.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/actions/payment_actions_provider.dart';
import 'package:mastercs_mobile/providers/data/payments_list_provider.dart';
import 'package:mastercs_mobile/providers/data/payments_by_user_provider.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/owner/currency_progress_carousel.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/owner/owner_payment_list_item.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/owner/add_payment_button.dart';

class OwnerPaymentsView extends ConsumerWidget {
  const OwnerPaymentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsListProvider);
    final userPaymentsAsync = ref.watch(userPaymentsProvider);
    final refreshController = PullToRefreshController();

    return paymentsAsync.when(
      loading: () => const Center(child: ThreeDotLoadingIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (payments) {
        return userPaymentsAsync.when(
          loading: () => const Center(child: ThreeDotLoadingIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
          data: (userPayments) {
            // Group payments by currency and calculate totals
            final Map<String, CurrencyData> currencyTotals = {};

            for (final payment in payments) {
              final paymentUsers = userPayments.values
                  .where((userMap) => userMap.containsKey(payment.remoteId))
                  .length;

              final paidUsers = userPayments.values
                  .where((userMap) => userMap[payment.remoteId] == true)
                  .length;

              final paymentExpected = payment.amount * paymentUsers;
              final paymentCollected = payment.amount * paidUsers;

              if (currencyTotals.containsKey(payment.currency)) {
                final existing = currencyTotals[payment.currency]!;
                currencyTotals[payment.currency] = CurrencyData(
                  currency: payment.currency,
                  totalExpected: existing.totalExpected + paymentExpected,
                  totalCollected: existing.totalCollected + paymentCollected,
                );
              } else {
                currencyTotals[payment.currency] = CurrencyData(
                  currency: payment.currency,
                  totalExpected: paymentExpected,
                  totalCollected: paymentCollected,
                );
              }
            }

            // Sort currencies by total expected (descending)
            final sortedCurrencyData = currencyTotals.values.toList()
              ..sort((a, b) => b.totalExpected.compareTo(a.totalExpected));

            return PullToRefresh(
              controller: refreshController,
              dragFactor: 0.2,
              onRefresh: () async {
                // Trigger a refresh of the payments data
                await ref
                    .read(paymentActionsProvider.notifier)
                    .refreshPayments();
                refreshController.completeRefresh();
              },
              triggerOffset: 80,
              child: CustomScrollView(
                slivers: [
                  if (payments.isEmpty)
                    const SliverToBoxAdapter(child: NoPaymentWidget()),

                  // Currency carousel header
                  SliverToBoxAdapter(
                    child: CurrencyProgressCarousel(
                      currencyData: sortedCurrencyData,
                    ),
                  ),

                  // Add payment button
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: AddPaymentButton(),
                    ),
                  ),

                  // Payments list
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final payment = payments[index];

                      // Count paid users for this payment
                      int totalUsers = 0;
                      int paidUsers = 0;

                      for (final userMap in userPayments.values) {
                        if (userMap.containsKey(payment.remoteId)) {
                          totalUsers++;
                          if (userMap[payment.remoteId] == true) {
                            paidUsers++;
                          }
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: OwnerPaymentListItem(
                          payment: payment,
                          paidCount: paidUsers,
                          totalCount: totalUsers,
                        ),
                      );
                    }, childCount: payments.length),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
