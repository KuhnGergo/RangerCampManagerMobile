import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:mastercs_mobile/core/api/http_response_extension.dart';
import 'api_exception_types.dart';

/// Base class for API exceptions
/// Represents an error returned from an API call.
/// Contains the error message, optional HTTP status code, and the original error object if any.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory ApiException.fromResponse(http.Response response) {
    String? errorMessage;
    try {
      final Map<String, dynamic> jsonBody = response.json;
      if (jsonBody.containsKey('message')) {
        errorMessage = jsonBody['message'];
      } else {
        errorMessage = 'Unknown error occurred';
      }
    } catch (_) {
      errorMessage = 'Unknown error occurred';
    }

    final exception = _mapStatusCodeToException(response);
    if (exception != null) {
      if (errorMessage == null) {
        return exception;
      }
      log('API error: $errorMessage (Status code: ${response.statusCode})');
      return exception;
    }

    return UnknownApiException(
      message: errorMessage!,
      statusCode: response.statusCode,
      originalError: response.json,
    );
  }

  static ApiException? _mapStatusCodeToException(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return BadRequestException(originalError: response.json);
      case 401:
        return UnauthorizedException(originalError: response.json);
      case 403:
        return ForbiddenException(originalError: response.json);
      case 404:
        return NotFoundException(originalError: response.json);
      case 409:
        return ConflictException(originalError: response.json);
      case 422:
        Map<String, List<String>>? errors;
        try {
          final Map<String, dynamic> jsonBody = json.decode(response.body);
          if (jsonBody.containsKey('errors')) {
            errors = (jsonBody['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, List<String>.from(value)),
            );
          }
        } catch (_) {
          // Ignore JSON parsing errors
        }
        return ValidationException(errors: errors);
      case 429:
        Duration? retryAfter;
        final retryAfterHeader = response.headers['retry-after'];
        if (retryAfterHeader != null) {
          final seconds = int.tryParse(retryAfterHeader);
          if (seconds != null) {
            retryAfter = Duration(seconds: seconds);
          }
        }
        return RateLimitException(retryAfter: retryAfter);
      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return ServerException(originalError: response.json);
      default:
        return null;
    }
  }

  factory ApiException.fromError(Object error, [StackTrace? stackTrace]) {
    if (error is ApiException) {
      return error;
    }

    // Handle timeout errors
    if (error.toString().contains('TimeoutException') ||
        error.toString().contains('timed out')) {
      return TimeoutException(originalError: error);
    }

    // Handle socket/network errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused') ||
        error.toString().contains('Network is unreachable')) {
      return NetworkException(originalError: error);
    }

    return UnknownApiException(message: error.toString(), originalError: error);
  }

  ApiException copyWith({
    String? message,
    int? statusCode,
    dynamic originalError,
  }) {
    return ApiException(
      message: message ?? this.message,
      statusCode: statusCode ?? this.statusCode,
      originalError: originalError ?? this.originalError,
    );
  }

  @override
  String toString() {
    return 'ApiException: $message (Status code: $statusCode)';
  }
}
