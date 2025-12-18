class ArchivedTournament {
  final int id;
  final String name;
  final String month;
  final int year;
  final String? startDate;
  final String? endDate;

  ArchivedTournament({
    required this.id,
    required this.name,
    required this.month,
    required this.year,
    this.startDate,
    this.endDate,
  });

  factory ArchivedTournament.fromJson(Map<String, dynamic> json) {
    return ArchivedTournament(
      id: json['id'] as int,
      name: json['name'] as String,
      month: json['month'] as String,
      year: json['year'] as int,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'month': month,
      'year': year,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  @override
  String toString() => '$name $month $year';
}

class TournamentPlayer {
  final int id;
  final String name;
  final int totalMatches;
  final int totalWins;
  final int totalTies;
  final int totalPointsScored;

  TournamentPlayer({
    required this.id,
    required this.name,
    required this.totalMatches,
    required this.totalWins,
    required this.totalTies,
    required this.totalPointsScored,
  });

  factory TournamentPlayer.fromJson(Map<String, dynamic> json) {
    return TournamentPlayer(
      id: json['id'] as int,
      name: json['name'] as String,
      totalMatches: json['total_matches'] as int? ?? 0,
      totalWins: json['total_wins'] as int? ?? 0,
      totalTies: json['total_ties'] as int? ?? 0,
      totalPointsScored: json['total_points_scored'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_matches': totalMatches,
      'total_wins': totalWins,
      'total_ties': totalTies,
      'total_points_scored': totalPointsScored,
    };
  }

  String get record =>
      '$totalWins-$totalTies-${totalMatches - totalWins - totalTies}';
}

class PlayerRace {
  final int id;
  final int tournamentId;
  final int playerId;
  final String playerName;
  final String? racePb;
  final String? raceBf;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  PlayerRace({
    required this.id,
    required this.tournamentId,
    required this.playerId,
    required this.playerName,
    this.racePb,
    this.raceBf,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory PlayerRace.fromJson(Map<String, dynamic> json) {
    return PlayerRace(
      id: json['id'] as int,
      tournamentId: json['tournament_id'] as int,
      playerId: json['player_id'] as int,
      playerName: json['player_name'] as String? ?? '',
      racePb: json['race_pb'] as String?,
      raceBf: json['race_bf'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'player_id': playerId,
      'player_name': playerName,
      'race_pb': racePb,
      'race_bf': raceBf,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  PlayerRace copyWith({String? racePb, String? raceBf, String? notes}) {
    return PlayerRace(
      id: id,
      tournamentId: tournamentId,
      playerId: playerId,
      playerName: playerName,
      racePb: racePb ?? this.racePb,
      raceBf: raceBf ?? this.raceBf,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
