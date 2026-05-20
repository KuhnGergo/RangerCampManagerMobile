import 'package:email_validator/email_validator.dart';

/// Utility class for form field validation
class Validators {
  /// Validates an email address
  ///
  /// Returns an error message if validation fails, null otherwise
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a password
  ///
  /// Returns an error message if validation fails, null otherwise
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 3) {
      return 'Password must be at least 3 characters';
    }
    return null;
  }

  /// Validates a username
  ///
  /// Returns an error message if validation fails, null otherwise
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    // Allow any Unicode letters, numbers, spaces, hyphens, and underscores
    // This supports UTF-8 characters including Hungarian (á, é, í, ó, ö, ő, ú, ü, ű)
    if (!RegExp(r'^[\p{L}\p{N}_ -]+$', unicode: true).hasMatch(value)) {
      return 'Username can only contain letters, numbers, spaces, hyphens, and underscores';
    }
    return null;
  }

  /// Validates a phone number (optional field)
  ///
  /// Returns an error message if validation fails, null otherwise
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }
    // Basic phone number validation - adjust regex based on your requirements
    if (!RegExp(
      r'^[+]?[0-9]{10,15}$',
    ).hasMatch(value.replaceAll(RegExp(r'[\s-()]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates password confirmation
  ///
  /// Returns an error message if validation fails, null otherwise
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates a join code
  ///
  /// Returns an error message if validation fails, null otherwise
  static String? joinCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Join code is required';
    }
    if (value.length < 6) {
      return 'Join code must be at least 6 characters';
    }
    if (value.length > 12) {
      return 'Join code must be less than 12 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'Join code can only contain letters and numbers';
    }
    return null;
  }

  static String? chatName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Chat name cannot be empty';
    }
    if (value.length < 3) {
      return 'Chat name must be at least 3 characters';
    }
    if (value.length > 50) {
      return 'Chat name must be less than 50 characters';
    }
    // Allow any Unicode letters, numbers, spaces, hyphens, and underscores
    if (!RegExp(r'^[\p{L}\p{N}_ -]+$', unicode: true).hasMatch(value)) {
      return 'Chat name can only contain letters, numbers, spaces, hyphens, and underscores';
    }
    return null;
  }
}
