class Standing {
  final int id;
  final String name;
  final int matchesPlayed;
  final int wins;
  final int ties;
  final int losses;
  final int points;
  final int totalPointsScored;

  Standing({
    required this.id,
    required this.name,
    required this.matchesPlayed,
    required this.wins,
    required this.ties,
    required this.losses,
    required this.points,
    required this.totalPointsScored,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    return Standing(
      id: json['id'] as int,
      name: json['name'] as String,
      matchesPlayed: json['matches_played'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      ties: json['ties'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      totalPointsScored: json['total_points_scored'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'matches_played': matchesPlayed,
      'wins': wins,
      'ties': ties,
      'losses': losses,
      'points': points,
      'total_points_scored': totalPointsScored,
    };
  }

  double get winRate => matchesPlayed > 0 ? wins / matchesPlayed : 0.0;
}
