import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mastercs_mobile/core/api/http_client.dart';
import 'api_config.dart';
import '../../data/api/endpoints.dart';

/// Provider for the API configuration.
///
/// This provider creates an [ApiConfig] based on the current environment.
/// It reads from the .env file to determine which environment to use.
final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig.fromEnvironment();
});

/// Provider for the API endpoints.
///
/// This provider depends on [apiConfigProvider] to create an [Endpoints] instance
/// that uses the current API configuration.
final endpointsProvider = Provider<Endpoints>((ref) {
  return Endpoints(ref.watch(apiConfigProvider));
});

/// Provider for the HTTP client.
///
/// This provider creates an [ApiHttpClient] instance configured with the
/// current API configuration.
final httpClientProvider = Provider<ApiHttpClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  return ApiHttpClient(config: config, ref: ref);
});
