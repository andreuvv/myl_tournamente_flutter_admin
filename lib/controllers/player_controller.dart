import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/player_service.dart';

class PlayerController extends ChangeNotifier {
  final PlayerService _service = PlayerService();

  List<Player> _players = [];
  bool _isLoading = false;
  String? _error;

  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlayers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _players = await _service.getPlayers();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _players = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPlayer(String name, bool confirmed) async {
    _error = null;

    try {
      final newPlayer = await _service.createPlayer(name, confirmed);
      _players.add(newPlayer);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePlayer(int id, String name, bool confirmed) async {
    _error = null;

    try {
      final updatedPlayer = await _service.updatePlayer(id, name, confirmed);
      final index = _players.indexWhere((p) => p.id == id);
      if (index != -1) {
        _players[index] = updatedPlayer;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlayer(int id) async {
    _error = null;

    try {
      await _service.deletePlayer(id);
      _players.removeWhere((p) => p.id == id);
      notifyListeners();
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
