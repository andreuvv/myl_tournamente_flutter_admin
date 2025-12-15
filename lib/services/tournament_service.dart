import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TournamentService {
  Future<void> archiveTournament({
    required String name,
    required String month,
    required int year,
    required String startDate,
    required String endDate,
  }) async {
    final requestBody = {
      'name': name,
      'month': month,
      'year': year,
      'start_date': startDate,
      'end_date': endDate,
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/tournaments/archive'),
        headers: ApiConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Try to parse error message from response
        String errorMessage = 'Unknown error';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['error'] ?? response.body;
        } catch (_) {
          errorMessage = response.body.isNotEmpty
              ? response.body
              : 'HTTP ${response.statusCode}';
        }
        throw Exception(
          'Archive failed (${response.statusCode}): $errorMessage',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: $e');
    }
  }

  Future<void> clearTournament({bool clearPlayers = false}) async {
    try {
      final url = clearPlayers
          ? '${ApiConfig.baseUrl}/tournament?clear_players=true'
          : '${ApiConfig.baseUrl}/tournament';

      final response = await http.delete(
        Uri.parse(url),
        headers: ApiConfig.headers,
      );

      if (response.statusCode != 200) {
        final errorBody = response.body.isNotEmpty
            ? response.body
            : 'No error details';
        throw Exception(
          'Failed to clear tournament: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      throw Exception('Error clearing tournament: $e');
    }
  }
}
