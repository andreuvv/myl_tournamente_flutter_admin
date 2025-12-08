class Match {
  final int id;
  final int roundNumber;
  final String format;
  final String player1Name;
  final String player2Name;
  final int? score1;
  final int? score2;
  final bool completed;
  final String? updatedAt;

  Match({
    required this.id,
    required this.roundNumber,
    required this.format,
    required this.player1Name,
    required this.player2Name,
    this.score1,
    this.score2,
    required this.completed,
    this.updatedAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as int,
      roundNumber: json['round_number'] as int,
      format: json['format'] as String,
      player1Name: json['player1_name'] as String,
      player2Name: json['player2_name'] as String,
      score1: json['score1'] as int?,
      score2: json['score2'] as int?,
      completed: json['completed'] as bool? ?? false,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'round_number': roundNumber,
      'format': format,
      'player1_name': player1Name,
      'player2_name': player2Name,
      'score1': score1,
      'score2': score2,
      'completed': completed,
      'updated_at': updatedAt,
    };
  }

  bool get isCompleted => completed;

  String? get winner {
    if (!completed || score1 == null || score2 == null) return null;
    if (score1! > score2!) return player1Name;
    if (score2! > score1!) return player2Name;
    return null; // Draw
  }

  bool get isDraw =>
      completed && score1 != null && score2 != null && score1 == score2;

  Match copyWith({
    int? id,
    int? roundNumber,
    String? format,
    String? player1Name,
    String? player2Name,
    int? score1,
    int? score2,
    bool? completed,
    String? updatedAt,
  }) {
    return Match(
      id: id ?? this.id,
      roundNumber: roundNumber ?? this.roundNumber,
      format: format ?? this.format,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      score1: score1 ?? this.score1,
      score2: score2 ?? this.score2,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
