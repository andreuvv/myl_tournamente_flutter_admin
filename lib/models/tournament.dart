class ArchivedTournament {
  final int id;
  final String name;
  final String month;
  final int year;
  final String? startDate;
  final String? endDate;
  final String? format;

  ArchivedTournament({
    required this.id,
    required this.name,
    required this.month,
    required this.year,
    this.startDate,
    this.endDate,
    this.format,
  });

  factory ArchivedTournament.fromJson(Map<String, dynamic> json) {
    return ArchivedTournament(
      id: json['id'] as int,
      name: json['name'] as String,
      month: json['month'] as String,
      year: json['year'] as int,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      format: json['format'] as String?,
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
      'format': format,
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
  final String? raceLibre;
  final String? raceEditionVcr;
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
    this.raceLibre,
    this.raceEditionVcr,
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
      raceLibre: json['race_libre'] as String?,
      raceEditionVcr: json['race_edition_vcr'] as String?,
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
      'race_libre': raceLibre,
      'race_edition_vcr': raceEditionVcr,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  PlayerRace copyWith({
    String? racePb,
    String? raceBf,
    String? raceLibre,
    String? raceEditionVcr,
    String? notes,
  }) {
    return PlayerRace(
      id: id,
      tournamentId: tournamentId,
      playerId: playerId,
      playerName: playerName,
      racePb: racePb ?? this.racePb,
      raceBf: raceBf ?? this.raceBf,
      raceLibre: raceLibre ?? this.raceLibre,
      raceEditionVcr: raceEditionVcr ?? this.raceEditionVcr,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
