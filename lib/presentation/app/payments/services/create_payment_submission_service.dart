import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/actions/payment_actions_provider.dart';

final createPaymentSubmissionServiceProvider =
    Provider<CreatePaymentSubmissionService>((ref) {
      final paymentActions = ref.read(paymentActionsProvider.notifier);
      return CreatePaymentSubmissionService(paymentActions);
    });

class CreatePaymentSubmissionService {
  final PaymentActionsNotifier _paymentActions;

  CreatePaymentSubmissionService(this._paymentActions);

  Future<void> submit({
    required String name,
    required int amountInMajor,
    required String currency,
    required DateTime dueDate,
  }) async {
    final amountInCents = amountInMajor * 100;

    await _paymentActions.addPayment(
      name: name.trim(),
      amount: amountInCents,
      currency: currency,
      dueDate: dueDate,
    );
  }
}
