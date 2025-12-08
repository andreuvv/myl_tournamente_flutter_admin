import 'package:flutter/foundation.dart';
import '../models/fixture.dart';
import '../services/fixture_service.dart';

class FixtureController extends ChangeNotifier {
  final FixtureService _service = FixtureService();

  Fixture? _fixture;
  bool _isLoading = false;
  String? _error;

  Fixture? get fixture => _fixture;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFixture() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _fixture = await _service.getFixture();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _fixture = null;
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
