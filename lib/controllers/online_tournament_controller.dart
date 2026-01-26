import 'package:flutter/foundation.dart';
import '../models/online_tournament.dart';
import '../models/online_match.dart';
import '../models/online_standing.dart';
import '../models/player.dart';
import '../services/online_tournament_service.dart';

class OnlineTournamentController extends ChangeNotifier {
  final OnlineTournamentService _service = OnlineTournamentService();

  OnlineTournament? _currentTournament;
  List<OnlineTournament> _activeTournaments = [];
  List<OnlineMatch> _allMatches = [];
  List<OnlineMatch> _pendingMatches = [];
  List<OnlineMatch> _completedMatches = [];
  List<OnlineStanding> _standings = [];
  List<Player> _premierPlayers = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  OnlineTournament? get currentTournament => _currentTournament;
  List<OnlineTournament> get activeTournaments => _activeTournaments;
  List<OnlineMatch> get allMatches => _allMatches;
  List<OnlineMatch> get pendingMatches => _pendingMatches;
  List<OnlineMatch> get completedMatches => _completedMatches;
  List<OnlineStanding> get standings => _standings;
  List<Player> get premierPlayers => _premierPlayers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPremierPlayers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _premierPlayers = await _service.getPremierPlayers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActiveTournaments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activeTournaments = await _service.getAllActiveTournaments();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OnlineTournament?> createOnlineTournament({
    required String name,
    required String month,
    required int year,
    required String format,
    required List<int> playerIds,
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tournament = await _service.createOnlineTournament(
        name: name,
        month: month,
        year: year,
        format: format,
        playerIds: playerIds,
        startDate: startDate,
        endDate: endDate,
      );
      _currentTournament = tournament;
      _error = null;
      notifyListeners();
      return tournament;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTournamentMatches(int tournamentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allMatches = await _service.getOnlineTournamentMatches(tournamentId);
      _pendingMatches = await _service.getPendingMatches(tournamentId);
      _completedMatches = await _service.getCompletedMatches(tournamentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTournamentStandings(int tournamentId) async {
    try {
      _standings = await _service.getOnlineTournamentStandings(tournamentId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateMatchScore(int matchId, int score1, int score2) async {
    _error = null;
    try {
      await _service.updateMatchScore(matchId, score1, score2);
      // Update local match
      final matchIndex = _allMatches.indexWhere((m) => m.id == matchId);
      if (matchIndex != -1) {
        _allMatches[matchIndex] = _allMatches[matchIndex].copyWith(
          score1: score1,
          score2: score2,
          completed: true,
        );
      }
      // Refresh standings and matches
      if (_currentTournament != null) {
        await loadTournamentStandings(_currentTournament!.id);
        await loadTournamentMatches(_currentTournament!.id);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadTournamentInfo(int tournamentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentTournament = await _service.getOnlineTournamentInfo(tournamentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOnlineTournament(int tournamentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteOnlineTournament(tournamentId);
      _currentTournament = null;
      _allMatches = [];
      _pendingMatches = [];
      _completedMatches = [];
      _standings = [];
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearTournament() {
    _currentTournament = null;
    _allMatches = [];
    _pendingMatches = [];
    _completedMatches = [];
    _standings = [];
    _error = null;
    notifyListeners();
  }
}
