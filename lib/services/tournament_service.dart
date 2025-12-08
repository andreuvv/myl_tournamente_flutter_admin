import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class TournamentService {
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
