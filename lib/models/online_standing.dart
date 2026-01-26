class OnlineStanding {
  final int tournamentId;
  final int playerId;
  final String playerName;
  final int matchesPlayed;
  final int wins;
  final int ties;
  final int losses;
  final int points;

  OnlineStanding({
    required this.tournamentId,
    required this.playerId,
    required this.playerName,
    required this.matchesPlayed,
    required this.wins,
    required this.ties,
    required this.losses,
    required this.points,
  });

  factory OnlineStanding.fromJson(Map<String, dynamic> json) {
    return OnlineStanding(
      tournamentId: json['tournament_id'] as int,
      playerId: json['player_id'] as int,
      playerName: json['player_name'] as String,
      matchesPlayed: json['matches_played'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      ties: json['ties'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournament_id': tournamentId,
      'player_id': playerId,
      'player_name': playerName,
      'matches_played': matchesPlayed,
      'wins': wins,
      'ties': ties,
      'losses': losses,
      'points': points,
    };
  }
}
