import 'api_exception.dart';

// Specific exceptions
// A bunch of classes. Nothing to look at.

/// Exception thrown when network is unavailable
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'No internet connection',
    super.originalError,
  }) : super(statusCode: null);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when request times out
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.originalError,
  }) : super(statusCode: null);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Exception thrown for unauthorized requests (401)
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Unauthorized access',
    super.originalError,
  }) : super(statusCode: 401);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception thrown for forbidden requests (403)
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access forbidden',
    super.originalError,
  }) : super(statusCode: 403);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Exception thrown when resource is not found (404)
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found. Please try again later.',
    super.originalError,
  }) : super(statusCode: 404);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown for validation errors (422)
class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    super.message = 'Validation failed',
    this.errors,
    super.originalError,
  }) : super(statusCode: 422);

  @override
  String toString() => 'ValidationException: $message, Errors: $errors';
}

/// Exception thrown for server errors (5xx)
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error occurred',
    super.statusCode = 500,
    super.originalError,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Exception thrown for bad requests (400)
class BadRequestException extends ApiException {
  const BadRequestException({
    super.message = 'Bad request',
    super.originalError,
  }) : super(statusCode: 400);

  @override
  String toString() => 'BadRequestException: $message';
}

/// Exception thrown for conflict errors (409)
class ConflictException extends ApiException {
  const ConflictException({
    super.message = 'Resource conflict',
    super.originalError,
  }) : super(statusCode: 409);

  @override
  String toString() => 'ConflictException: $message';
}

/// Exception thrown for too many requests (429)
class RateLimitException extends ApiException {
  final Duration? retryAfter;

  const RateLimitException({
    super.message = 'Too many requests',
    this.retryAfter,
    super.originalError,
  }) : super(statusCode: 429);

  @override
  String toString() => 'RateLimitException: $message, Retry after: $retryAfter';
}

/// Exception thrown for unknown errors
class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'An unknown error occurred',
    super.statusCode,
    super.originalError,
  });

  @override
  String toString() => 'UnknownApiException: $message (Status: $statusCode)';
}
