import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/schema/app_database.dart';
import 'package:mastercs_mobile/models/member.dart';
import 'package:mastercs_mobile/models/roles.dart';
import 'package:mastercs_mobile/providers/data/payments_by_user_provider.dart';
import 'package:mastercs_mobile/providers/data/camp_members_list_provider.dart';

class PaymentDetailData {
  final bool isLoading;
  final Map<String, Map<String, bool>> userPayments;
  final List<Member> campers;

  PaymentDetailData({
    required this.isLoading,
    required this.userPayments,
    required this.campers,
  });

  PaymentDetailData.loading()
    : isLoading = true,
      userPayments = {},
      campers = [];

  int get totalCampers => campers.length;

  int getPaidCount(Payment payment) {
    return campers.where((member) {
      return userPayments[member.userRemoteId]?[payment.remoteId] == true;
    }).length;
  }

  double getProgress(Payment payment) {
    if (totalCampers == 0) return 0.0;
    return getPaidCount(payment) / totalCampers;
  }

  bool isMemberPaid(String userId, String paymentId) {
    return userPayments[userId.toString()]?[paymentId.toString()] == true;
  }

  List<Member> getFilteredMembers({
    required String searchQuery,
    required bool showOnlyUnpaid,
    required Payment payment,
  }) {
    final filtered = campers.where((member) {
      // Check search query
      if (searchQuery.isNotEmpty) {
        final name = member.name.toLowerCase();
        if (!name.contains(searchQuery)) return false;
      }

      // Check unpaid filter
      if (showOnlyUnpaid) {
        final isPaid =
            userPayments[member.userRemoteId]?[payment.remoteId] == true;
        if (isPaid) return false;
      }

      return true;
    }).toList();

    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }
}

final paymentDetailDataProvider = Provider<PaymentDetailData>((ref) {
  final userPaymentsAsync = ref.watch(userPaymentsProvider);
  final membersAsync = ref.watch(campMembersListProvider);

  // Check if either is loading
  final isLoading = userPaymentsAsync.isLoading || membersAsync.isLoading;

  // If loading, return loading state
  if (isLoading) {
    return PaymentDetailData.loading();
  }

  // Get values with defaults
  final Map<String, Map<String, bool>> userPayments = userPaymentsAsync.hasValue
      ? userPaymentsAsync.value!
      : {};
  final List<Member> allMembers = membersAsync.hasValue
      ? membersAsync.value!
      : [];
  final List<Member> campers = allMembers
      .where((m) => m.role == Role.camper.stringName)
      .toList();

  return PaymentDetailData(
    isLoading: false,
    userPayments: userPayments,
    campers: campers,
  );
});
