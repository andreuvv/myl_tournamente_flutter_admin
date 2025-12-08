import 'match.dart';

class FixtureRound {
  final int number;
  final String format;
  final List<Match> matches;

  FixtureRound({
    required this.number,
    required this.format,
    required this.matches,
  });

  factory FixtureRound.fromJson(Map<String, dynamic> json) {
    return FixtureRound(
      number: json['number'] as int,
      format: json['format'] as String,
      matches: (json['matches'] as List<dynamic>)
          .map((m) => Match.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'format': format,
      'matches': matches.map((m) => m.toJson()).toList(),
    };
  }
}

class Fixture {
  final List<FixtureRound> rounds;

  Fixture({required this.rounds});

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
      rounds: (json['rounds'] as List<dynamic>)
          .map((r) => FixtureRound.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'rounds': rounds.map((r) => r.toJson()).toList()};
  }
}
