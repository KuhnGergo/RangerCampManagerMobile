import 'package:flutter_dotenv/flutter_dotenv.dart';

// Set environment configuration

enum Environment { development, staging, production }

class ApiConfig {
  final Environment environment;
  final String baseUrl;

  /// Used for GET request timeout
  final Duration receiveTimeout;

  /// Used for POST, PUT, DELETE request timeout
  final Duration sendTimeout;

  const ApiConfig._({
    required this.environment,
    required this.baseUrl,
    // ignore: unused_element_parameter
    this.receiveTimeout = const Duration(seconds: 10),
    // ignore: unused_element_parameter
    this.sendTimeout = const Duration(seconds: 10),
  });

  factory ApiConfig.development() {
    return ApiConfig._(
      environment: Environment.development,
      baseUrl: dotenv.env['DEV_API_URL']!,
    );
  }
  factory ApiConfig.staging() {
    return ApiConfig._(
      environment: Environment.staging,
      baseUrl: dotenv.env['API_URL']!,
    );
  }
  factory ApiConfig.production() {
    return ApiConfig._(
      environment: Environment.production,
      baseUrl: dotenv.env['API_URL']!,
    );
  }

  factory ApiConfig.fromEnvironment() {
    final envString = dotenv.env['ENVIRONMENT'] ?? 'production';

    switch (envString.toLowerCase()) {
      case 'local':
      case 'dev':
      case 'development':
        if (dotenv.env['DEV_API_URL'] == null) {
          throw Exception(
            'DEV_API_URL must be set for development environment',
          );
        }
        return ApiConfig.development();
      case 'stage':
      case 'staging':
        if (dotenv.env['API_URL'] == null) {
          throw Exception('API_URL must be set for staging environment');
        }
        return ApiConfig.staging();
      case 'prod':
      case 'production':
        if (dotenv.env['API_URL'] == null) {
          throw Exception('API_URL must be set for production environment');
        }
        return ApiConfig.production();
      default:
        return ApiConfig.production();
    }
  }
}
