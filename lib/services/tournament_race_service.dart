import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/tournament.dart';

class TournamentRaceService {
  Future<List<TournamentPlayer>> getArchivedTournamentPlayers(
    int tournamentId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/tournaments/$tournamentId/players'),
        headers: ApiConfig.headers,
      );

      print('getArchivedTournamentPlayers status: ${response.statusCode}');
      print('getArchivedTournamentPlayers body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TournamentPlayer.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load tournament players: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getArchivedTournamentPlayers: $e');
      throw Exception('Error fetching tournament players: $e');
    }
  }

  Future<List<PlayerRace>> getTournamentPlayerRaces(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/tournaments/$tournamentId/player-races',
        ),
        headers: ApiConfig.headers,
      );

      print('getTournamentPlayerRaces status: ${response.statusCode}');
      print('getTournamentPlayerRaces body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PlayerRace.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load player races: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTournamentPlayerRaces: $e');
      throw Exception('Error fetching player races: $e');
    }
  }

  Future<void> updatePlayerRace(
    int tournamentId,
    int playerId,
    String? racePb,
    String? raceBf,
    String? notes,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '${ApiConfig.baseUrl}/tournaments/$tournamentId/players/$playerId/race',
        ),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'race_pb': racePb,
          'race_bf': raceBf,
          'notes': notes,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update player race: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating player race: $e');
    }
  }
}
