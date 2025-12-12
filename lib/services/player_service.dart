import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/player.dart';

class PlayerService {
  Future<List<Player>> getPlayers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/players'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Player.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load players: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching players: $e');
    }
  }

  Future<Player> createPlayer(String name, bool confirmed) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/players'),
        headers: ApiConfig.headers,
        body: json.encode({'name': name, 'confirmed': confirmed}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Player.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create player: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating player: $e');
    }
  }

  Future<void> deletePlayer(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/players/$id'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete player: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting player: $e');
    }
  }

  Future<Player> updatePlayer(int id, String name, bool confirmed) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/players/$id'),
        headers: ApiConfig.headers,
        body: json.encode({'name': name, 'confirmed': confirmed}),
      );

      if (response.statusCode == 200) {
        return Player.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update player: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating player: $e');
    }
  }

  Future<Player> togglePlayerConfirmed(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/players/$id/confirm'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return Player.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to toggle player confirmation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling player confirmation: $e');
    }
  }

  Future<List<Player>> getConfirmedPlayers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/players/confirmed'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Player.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load confirmed players: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching confirmed players: $e');
    }
  }
}
