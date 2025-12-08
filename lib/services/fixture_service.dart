import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/fixture.dart';

class FixtureService {
  Future<Fixture> getFixture() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/fixture'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Fixture.fromJson(data);
      } else {
        throw Exception('Failed to load fixture: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fixture: $e');
    }
  }

  Future<void> createFixture(Map<String, dynamic> fixtureData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/fixture'),
        headers: ApiConfig.headers,
        body: json.encode(fixtureData),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to create fixture: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating fixture: $e');
    }
  }
}
