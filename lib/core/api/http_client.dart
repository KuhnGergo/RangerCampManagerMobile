import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/providers/auth/auth_provider.dart';
import 'package:mastercs_mobile/providers/auth/session_flow.dart';

import 'api_config.dart';

class ApiHttpClient {
  final ApiConfig config;
  final http.Client _client;
  final Ref ref;

  ApiHttpClient({required this.config, required this.ref, http.Client? client})
    : _client = client ?? http.Client();

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Merge custom headers with default headers
  Map<String, String> _appendHeaders(
    Map<String, String> headers,
    Map<String, String>? newHeaders,
  ) {
    return {...headers, ...?newHeaders};
  }

  Map<String, String> _appendAuthHeader(Map<String, String> headers) {
    final token = ref.read(authProvider.notifier).getToken;
    headers['Authorization'] = 'Bearer $token';

    return headers;
  }

  /// Check for 401 and trigger logout
  void _handleUnauthorized(http.Response response) {
    if (response.statusCode == 401) {
      // Trigger logout without waiting
      ref.read(sessionFlowProvider.notifier).logout();
    }
  }

  /// Perform a GET request
  /// [route]: The completed endpoint route (parameters must be replaced)
  /// [useAuth]: Whether to include the Authorization header
  /// [headers]: Additional headers to include in the request
  Future<http.Response> get(
    String route, {
    bool auth = true,
    Map<String, String>? headers,
  }) async {
    var uri = Uri.parse(route);

    final response = await _client
        .get(
          uri,
          headers: _appendHeaders(_defaultHeaders, headers)
            ..addAll(auth ? _appendAuthHeader({}) : {}),
        )
        .timeout(config.receiveTimeout);

    _handleUnauthorized(response);
    return response;
  }

  Future<http.Response> getWithBody(
    String route, {
    Object? body,
    bool auth = true,
    Map<String, String>? headers,
  }) async {
    var uri = Uri.parse(route);

    final request = http.Request('GET', uri);
    request.headers.addAll(
      _appendHeaders(_defaultHeaders, headers)
        ..addAll(auth ? _appendAuthHeader({}) : {}),
    );
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamedResponse = await _client
        .send(request)
        .timeout(config.receiveTimeout);
    final response = await http.Response.fromStream(streamedResponse);

    _handleUnauthorized(response);
    return response;
  }

  /// Perform a POST request
  Future<http.Response> post(
    String route, {
    Object? body,
    bool auth = true,
    Map<String, String>? headers,
  }) async {
    var uri = Uri.parse(route);

    final response = await _client
        .post(
          uri,
          headers: _appendHeaders(_defaultHeaders, headers)
            ..addAll(auth ? _appendAuthHeader({}) : {}),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(config.sendTimeout);

    if (auth) {
      _handleUnauthorized(response);
    }
    return response;
  }

  /// Perform a PUT request
  Future<http.Response> put(
    String route, {
    bool auth = true,
    Object? body,
    Map<String, String>? headers,
  }) async {
    var uri = Uri.parse(route);

    final response = await _client
        .put(
          uri,
          headers: _appendHeaders(_defaultHeaders, headers)
            ..addAll(auth ? _appendAuthHeader({}) : {}),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(config.sendTimeout);

    if (auth) {
      _handleUnauthorized(response);
    }
    return response;
  }

  /// Perform a PATCH request
  Future<http.Response> patch(
    String route, {
    Object? body,
    bool auth = true,
    Map<String, String>? headers,
  }) async {
    var uri = Uri.parse(route);

    final response = await _client
        .patch(
          uri,
          headers: _appendHeaders(_defaultHeaders, headers)
            ..addAll(auth ? _appendAuthHeader({}) : {}),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(config.sendTimeout);

    if (auth) {
      _handleUnauthorized(response);
    }
    return response;
  }

  /// Perform a DELETE request
  Future<http.Response> delete(
    String route, {
    Object? body,
    bool auth = true,
    Map<String, String>? headers,
  }) async {
    var uri = Uri.parse(route);

    final response = await _client
        .delete(
          uri,
          headers: _appendHeaders(_defaultHeaders, headers)
            ..addAll(auth ? _appendAuthHeader({}) : {}),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(config.sendTimeout);

    if (auth) {
      _handleUnauthorized(response);
    }
    return response;
  }

  /// Upload binary data (e.g., images) with application/octet-stream
  Future<http.Response> uploadBinary(
    String route, {
    required File file,
    bool auth = true,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(route);
    final bytes = await file.readAsBytes();

    final customHeaders = {
      'Content-Type': 'application/octet-stream',
      ...?headers,
    };

    final response = await _client
        .post(
          uri,
          headers: auth ? _appendAuthHeader(customHeaders) : customHeaders,
          body: bytes,
        )
        .timeout(config.sendTimeout);

    if (auth) {
      _handleUnauthorized(response);
    }
    return response;
  }

  /// Close the client when done
  void close() {
    _client.close();
  }
}
