import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/app/payments/provider/payment_detail_data_provider.dart';
import 'package:mastercs_mobile/providers/actions/payment_actions_provider.dart';

class MemberPaymentStatusItem extends ConsumerWidget {
  final Member member;
  final Payment payment;

  const MemberPaymentStatusItem({
    super.key,
    required this.member,
    required this.payment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final paymentActions = ref.read(paymentActionsProvider.notifier);
    final isPaid = ref
        .read(paymentDetailDataProvider)
        .isMemberPaid(member.userRemoteId, payment.remoteId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? colorScheme.primary.withAlpha(100)
              : colorScheme.outline.withAlpha(50),
          width: 1.5,
        ),
        boxShadow: isPaid
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            try {
              await paymentActions.setUserPayment(
                paymentId: payment.remoteId,
                userId: member.userRemoteId,
                isPaid: !isPaid,
              );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isPaid
                        ? LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withAlpha(200),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isPaid ? null : colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: isPaid
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPaid
                                  ? colorScheme.primary
                                  : colorScheme.error,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPaid ? 'Paid' : 'Unpaid',
                            style: TextStyle(
                              color: isPaid
                                  ? colorScheme.primary
                                  : colorScheme.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Custom Toggle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPaid
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: isPaid
                          ? colorScheme.primary
                          : colorScheme.outline.withAlpha(80),
                      width: 2,
                    ),
                  ),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isPaid ? 1.0 : 0.0,
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
