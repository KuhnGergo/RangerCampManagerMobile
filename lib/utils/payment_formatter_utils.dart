import 'package:currency_formatter/currency_formatter.dart';

class PaymentFormatterUtils {
  static String formatAmount(int amount, String currencyCode) {
    return CurrencyFormatter.format(
      amount,
      CurrencyFormat.fromCode(currencyCode) ?? CurrencyFormat.usd,
    );
  }

  static String getCurrencySymbol(String currencyCode) {
    final format = CurrencyFormat.fromCode(currencyCode) ?? CurrencyFormat.usd;
    return format.symbol;
  }
}
