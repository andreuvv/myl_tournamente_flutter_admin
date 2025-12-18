import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../services/tournament_race_service.dart';

class TournamentRaceController extends ChangeNotifier {
  final TournamentService _tournamentService = TournamentService();
  final TournamentRaceService _raceService = TournamentRaceService();

  List<ArchivedTournament> tournaments = [];
  List<TournamentPlayer> selectedTournamentPlayers = [];
  Map<int, PlayerRace> playerRaces = {}; // Map of playerId -> PlayerRace

  bool isLoadingTournaments = false;
  bool isLoadingPlayers = false;
  bool isLoadingRaces = false;
  bool isSaving = false;

  String? errorMessage;
  ArchivedTournament? selectedTournament;

  // Load all archived tournaments
  Future<void> loadArchivedTournaments() async {
    isLoadingTournaments = true;
    errorMessage = null;
    notifyListeners();

    try {
      tournaments = await _tournamentService.getTournaments();
      isLoadingTournaments = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoadingTournaments = false;
      notifyListeners();
    }
  }

  // Load players for selected tournament
  Future<void> loadTournamentPlayers(ArchivedTournament tournament) async {
    selectedTournament = tournament;
    isLoadingPlayers = true;
    isLoadingRaces = true;
    errorMessage = null;
    notifyListeners();

    try {
      print('Loading players for tournament: ${tournament.id}');
      // Load both players and their race data in parallel
      final playersResult = await _raceService.getArchivedTournamentPlayers(
        tournament.id,
      );
      print('Players result: ${playersResult.length} players');

      final racesResult = await _raceService.getTournamentPlayerRaces(
        tournament.id,
      );
      print('Races result: ${racesResult.length} races');

      selectedTournamentPlayers = playersResult;

      // Create a map of existing player races for quick lookup
      playerRaces.clear();
      for (var race in racesResult) {
        playerRaces[race.playerId] = race;
      }

      isLoadingPlayers = false;
      isLoadingRaces = false;
      notifyListeners();
    } catch (e) {
      print('Error loading tournament players: $e');
      errorMessage = e.toString();
      isLoadingPlayers = false;
      isLoadingRaces = false;
      notifyListeners();
    }
  }

  // Get or create player race data
  PlayerRace getOrCreatePlayerRace(TournamentPlayer player) {
    if (playerRaces.containsKey(player.id)) {
      return playerRaces[player.id]!;
    }

    // Create a new empty race record
    return PlayerRace(
      id: 0,
      tournamentId: selectedTournament?.id ?? 0,
      playerId: player.id,
      playerName: player.name,
      racePb: null,
      raceBf: null,
      notes: null,
    );
  }

  // Update player race data
  void updatePlayerRaceLocal(
    int playerId,
    String? racePb,
    String? raceBf,
    String? notes,
  ) {
    if (playerRaces.containsKey(playerId)) {
      playerRaces[playerId] = playerRaces[playerId]!.copyWith(
        racePb: racePb,
        raceBf: raceBf,
        notes: notes,
      );
    } else {
      final tournament = selectedTournament;
      if (tournament != null) {
        playerRaces[playerId] = PlayerRace(
          id: 0,
          tournamentId: tournament.id,
          playerId: playerId,
          playerName: '',
          racePb: racePb,
          raceBf: raceBf,
          notes: notes,
        );
      }
    }
    notifyListeners();
  }

  // Save player race data to backend
  Future<bool> savePlayerRace(
    int playerId,
    String? racePb,
    String? raceBf,
    String? notes,
  ) async {
    if (selectedTournament == null) return false;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _raceService.updatePlayerRace(
        selectedTournament!.id,
        playerId,
        racePb,
        raceBf,
        notes,
      );

      // Update local cache
      updatePlayerRaceLocal(playerId, racePb, raceBf, notes);

      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // Clear selection
  void clearSelection() {
    selectedTournament = null;
    selectedTournamentPlayers.clear();
    playerRaces.clear();
    errorMessage = null;
    notifyListeners();
  }
}
