import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/match.dart';
import '../models/fixture.dart';

class MatchService {
  Future<List<Match>> getAllMatches() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/fixture'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fixture = Fixture.fromJson(data);

        // Flatten all matches from all rounds
        final List<Match> allMatches = [];
        for (final round in fixture.rounds) {
          allMatches.addAll(round.matches);
        }
        return allMatches;
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching matches: $e');
    }
  }

  Future<void> updateMatchResult({
    required int matchId,
    required int score1,
    required int score2,
  }) async {
    try {
      final body = json.encode({'score1': score1, 'score2': score2});

      print('Updating match $matchId with body: $body'); // Debug log

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/matches/$matchId/score'),
        headers: ApiConfig.headers,
        body: body,
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode != 200) {
        final errorBody = response.body.isNotEmpty
            ? response.body
            : 'No error details';
        throw Exception(
          'Failed to update match: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      throw Exception('Error updating match: $e');
    }
  }
}
