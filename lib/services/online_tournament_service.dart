import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/online_tournament.dart';
import '../models/online_match.dart';
import '../models/online_standing.dart';
import '../models/player.dart';

class OnlineTournamentService {
  Future<List<Player>> getPremierPlayers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/premier-players'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Player.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load premier players: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching premier players: $e');
    }
  }

  Future<OnlineTournament> createOnlineTournament({
    required String name,
    required String month,
    required int year,
    required String format,
    required List<int> playerIds,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/tournaments/online'),
        headers: ApiConfig.headers,
        body: json.encode({
          'name': name,
          'month': month,
          'year': year,
          'format': format,
          'player_ids': playerIds,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return OnlineTournament(
          id: data['tournament_id'] as int,
          name: data['tournament_name'] as String,
          month: month,
          year: year,
          format: format,
          type: 'ONLINE',
          startDate: startDate,
          endDate: endDate,
          createdAt: DateTime.now().toIso8601String(),
        );
      } else {
        throw Exception('Failed to create tournament: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating tournament: $e');
    }
  }

  Future<List<OnlineMatch>> getOnlineTournamentMatches(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/tournaments/online/$tournamentId/matches',
        ),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OnlineMatch.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching matches: $e');
    }
  }

  Future<List<OnlineMatch>> getPendingMatches(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/tournaments/online/$tournamentId/matches/pending',
        ),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OnlineMatch.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load pending matches: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching pending matches: $e');
    }
  }

  Future<List<OnlineMatch>> getCompletedMatches(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/tournaments/online/$tournamentId/matches/completed',
        ),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OnlineMatch.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load completed matches: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching completed matches: $e');
    }
  }

  Future<void> updateMatchScore(int matchId, int score1, int score2) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/tournaments/online/matches/$matchId'),
        headers: ApiConfig.headers,
        body: json.encode({'score1': score1, 'score2': score2}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update match score: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating match score: $e');
    }
  }

  Future<List<OnlineStanding>> getOnlineTournamentStandings(
    int tournamentId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/tournaments/online/$tournamentId/standings',
        ),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => OnlineStanding.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load standings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching standings: $e');
    }
  }

  Future<OnlineTournament> getOnlineTournamentInfo(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/tournaments/online/$tournamentId/info'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return OnlineTournament.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to load tournament info: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching tournament info: $e');
    }
  }

  Future<void> deleteOnlineTournament(int tournamentId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/tournaments/online/$tournamentId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete tournament: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting tournament: $e');
    }
  }

  Future<List<OnlineTournament>> getAllActiveTournaments() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/tournaments/active'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .where((t) => t['type'] == 'ONLINE')
            .map((json) => OnlineTournament.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load active tournaments: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching active tournaments: $e');
    }
  }
}
