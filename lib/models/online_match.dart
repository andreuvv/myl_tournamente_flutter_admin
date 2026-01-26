class OnlineMatch {
  final int id;
  final int tournamentId;
  final int player1Id;
  final int player2Id;
  final String player1Name;
  final String player2Name;
  final int? score1;
  final int? score2;
  final bool completed;
  final String? matchDate;
  final String createdAt;
  final String updatedAt;

  OnlineMatch({
    required this.id,
    required this.tournamentId,
    required this.player1Id,
    required this.player2Id,
    required this.player1Name,
    required this.player2Name,
    this.score1,
    this.score2,
    required this.completed,
    this.matchDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OnlineMatch.fromJson(Map<String, dynamic> json) {
    return OnlineMatch(
      id: json['id'] as int,
      tournamentId: json['tournament_id'] as int,
      player1Id: json['player1_id'] as int,
      player2Id: json['player2_id'] as int,
      player1Name: json['player1_name'] as String,
      player2Name: json['player2_name'] as String,
      score1: json['score1'] as int?,
      score2: json['score2'] as int?,
      completed: json['completed'] as bool? ?? false,
      matchDate: json['match_date'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'player1_id': player1Id,
      'player2_id': player2Id,
      'player1_name': player1Name,
      'player2_name': player2Name,
      'score1': score1,
      'score2': score2,
      'completed': completed,
      'match_date': matchDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  OnlineMatch copyWith({int? score1, int? score2, bool? completed}) {
    return OnlineMatch(
      id: id,
      tournamentId: tournamentId,
      player1Id: player1Id,
      player2Id: player2Id,
      player1Name: player1Name,
      player2Name: player2Name,
      score1: score1 ?? this.score1,
      score2: score2 ?? this.score2,
      completed: completed ?? this.completed,
      matchDate: matchDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
