import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/standing.dart';

class StandingsService {
  Future<List<Standing>> getStandings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/standings'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Standing.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load standings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching standings: $e');
    }
  }
}
