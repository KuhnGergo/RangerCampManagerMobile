import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/presentation/components/widgets/three_dot_loading_indicator.dart';
import 'package:mastercs_mobile/providers/data/payments_by_user_provider.dart';
import 'package:mastercs_mobile/providers/data/payments_list_provider.dart';

import 'payment_item_tile.dart';
import 'payment_summary_bar.dart';
import 'profile_section_card.dart';

/// Owner-only section: shows all payments and the user's payment status.
/// Title and progress summary are always visible; the list is collapsed by default.
class PaymentsSection extends ConsumerStatefulWidget {
  final String userId;

  const PaymentsSection({super.key, required this.userId});

  @override
  ConsumerState<PaymentsSection> createState() => _PaymentsSectionState();
}

class _PaymentsSectionState extends ConsumerState<PaymentsSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsListProvider);
    final userPaymentsAsync = ref.watch(userPaymentsProvider);

    return paymentsAsync.when(
      data: (payments) => userPaymentsAsync.when(
        data: (allUserPayments) {
          if (payments.isEmpty) {
            return SizedBox.shrink(); // Don't show section if there are no payments
          }

          final userPayments = allUserPayments[widget.userId] ?? {};
          final paidCount = userPayments.values.where((paid) => paid).length;

          final sortedPayments = payments
            ..sort(
              (a, b) => a.dueDate?.compareTo(b.dueDate ?? DateTime.now()) ?? 0,
            );

          return ProfileSectionCard(
            title: 'Payments',
            children: [
              PaymentSummaryBar(
                paidCount: paidCount,
                totalCount: payments.length,
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isExpanded
                    ? const SizedBox.shrink()
                    : _ExpandButton(onTap: _toggle),
              ),
              SizeTransition(
                sizeFactor: _animation,
                axisAlignment: -1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    const SizedBox(height: 8),
                    ...sortedPayments.map(
                      (payment) => PaymentItemTile(
                        payment: payment,
                        userId: widget.userId,
                      ),
                    ),
                    _CollapseButton(onTap: _toggle),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const _LoadingPayments(),
        error: (e, _) => const SizedBox.shrink(),
      ),
      loading: () => const _LoadingPayments(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _ExpandButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ExpandButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Align(
        alignment: Alignment.center,
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.expand_more, size: 18),
          label: const Text('Show payments'),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ),
    );
  }
}

class _CollapseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CollapseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.expand_less, size: 18),
        label: const Text('Hide payments'),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
      ),
    );
  }
}

class _LoadingPayments extends StatelessWidget {
  const _LoadingPayments();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: ThreeDotLoadingIndicator()),
    );
  }
}
