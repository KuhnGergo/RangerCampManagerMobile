class SocketError {
  final String code;
  final String message;

  SocketError({required this.code, required this.message});

  factory SocketError.fromJson(Map<String, dynamic> json) {
    return SocketError(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  @override
  String toString() => 'SocketError(code: $code, message: $message)';
}

// Error codes from backend
class SocketErrorCodes {
  static const String internalError = 'INTERNAL_ERROR';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String rateLimitExceeded = 'RATE_LIMIT_EXCEEDED';
  static const String invalidInput = 'INVALID_INPUT';
  static const String textTooLong = 'TEXT_TOO_LONG';
  static const String invalidReply = 'INVALID_REPLY';
  static const String validationError = 'VALIDATION_ERROR';
  static const String notFound = 'NOT_FOUND';
}
