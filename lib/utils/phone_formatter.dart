import 'package:dlibphonenumber/dlibphonenumber.dart';

/// Utility functions for formatting phone numbers.
class PhoneFormatter {
  static final _phoneNumberUtil = PhoneNumberUtil.instance;

  /// Format a phone number string to international format (E.164).
  /// If formatting fails, returns the original string.
  ///
  /// Example: "1234567890" → "+11234567890"
  /// Example: "+1 (234) 567-8900" → "+12345678900"
  static String formatInternational(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    try {
      // Try to parse and format the number in E.164 format
      final parsed = _phoneNumberUtil.parse(phoneNumber, null);
      return _phoneNumberUtil.format(parsed, PhoneNumberFormat.e164);
    } catch (_) {
      // If parsing fails, return original string
      return phoneNumber;
    }
  }

  /// Format a phone number to a readable format (e.g., +1 (234) 567-8900).
  /// If formatting fails, returns the original string.
  static String formatReadable(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    try {
      final parsed = _phoneNumberUtil.parse(phoneNumber, null);
      return _phoneNumberUtil.format(parsed, PhoneNumberFormat.international);
    } catch (_) {
      return phoneNumber;
    }
  }

  /// Format a phone number to national format (e.g., (234) 567-8900 for US).
  /// If formatting fails, returns the original string.
  static String formatNational(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    try {
      final parsed = _phoneNumberUtil.parse(phoneNumber, null);
      return _phoneNumberUtil.format(parsed, PhoneNumberFormat.national);
    } catch (_) {
      return phoneNumber;
    }
  }
}
