import 'package:flutter/foundation.dart';
import '../models/standing.dart';
import '../services/standings_service.dart';

class StandingsController extends ChangeNotifier {
  final StandingsService _service = StandingsService();

  List<Standing> _standings = [];
  bool _isLoading = false;
  String? _error;

  List<Standing> get standings => _standings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStandings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _standings = await _service.getStandings();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _standings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
