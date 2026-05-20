import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mastercs_mobile/core/api/api_exception.dart';

// Newly added getters and methods for http.Response variable type.
// Now on any http.Response object, these methods can be called.
// For example:
//   final response = await http.get(...);
//   final data = response.json; // parses body as JSON

/// Extension for parsing API responses
extension ResponseExtension on http.Response {
  /// Parse response body as JSON
  dynamic get json => jsonDecode(body);

  /// Safely parse JSON, returns null if parsing fails
  dynamic get jsonOrNull {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  /// Check if response is successful (2xx)
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// Check if response is client error (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Check if response is server error (5xx)
  bool get isServerError => statusCode >= 500;

  /// Check if unauthorized (401)
  bool get isUnauthorized => statusCode == 401;

  /// Check if forbidden (403)
  bool get isForbidden => statusCode == 403;

  /// Check if not found (404)
  bool get isNotFound => statusCode == 404;

  /// Throws an [ApiException] if the response is not successful.
  /// Returns the response for chaining if successful.
  ///
  /// Usage:
  /// ```dart
  /// final response = await client.get('/users').throwIfError();
  /// final data = response.json;
  /// ```
  http.Response throwIfError() {
    if (isSuccess) return this;
    throw ApiException.fromResponse(this);
  }

  /// Returns the JSON body if successful, throws [ApiException] otherwise.
  ///
  /// Usage:
  /// ```dart
  /// final data = await client.get('/users').then((r) => r.jsonOrThrow);
  /// ```
  dynamic get jsonOrThrow {
    throwIfError();
    return json;
  }
}
