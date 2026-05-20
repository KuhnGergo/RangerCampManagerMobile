import 'package:flutter/material.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/presentation/app/payments/widgets/payment_detail/member_payment_status_item.dart';

class UserPaymentsList extends StatelessWidget {
  final List<Member> filteredMembers;
  final Payment payment;

  const UserPaymentsList({
    super.key,
    required this.filteredMembers,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (filteredMembers.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Well done! ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: textTheme.headlineSmall!.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'All campers have paid for this item.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: textTheme.bodyLarge!.fontSize,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMembers.length,
      itemBuilder: (context, index) {
        final member = filteredMembers[index];

        return MemberPaymentStatusItem(member: member, payment: payment);
      },
    );
  }
}
