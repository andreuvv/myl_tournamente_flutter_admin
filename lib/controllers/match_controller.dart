import 'package:flutter/foundation.dart';
import '../models/match.dart';
import '../services/match_service.dart';

class MatchController extends ChangeNotifier {
  final MatchService _service = MatchService();

  List<Match> _matches = [];
  bool _isLoading = false;
  String? _error;

  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllMatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matches = await _service.getAllMatches();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _matches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMatchResult(int matchId, int score1, int score2) async {
    _error = null;

    try {
      await _service.updateMatchResult(
        matchId: matchId,
        score1: score1,
        score2: score2,
      );

      // Reload all matches after update
      await loadAllMatches();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
