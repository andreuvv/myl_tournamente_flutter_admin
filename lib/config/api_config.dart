import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Load from environment variables
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Endpoints
  static const String playersEndpoint = '/players';
  static const String fixturesEndpoint = '/fixtures';
  static const String matchesEndpoint = '/matches';
  static const String standingsEndpoint = '/standings';
  static const String roundsEndpoint = '/rounds';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'X-API-Key': apiKey,
  };
}
