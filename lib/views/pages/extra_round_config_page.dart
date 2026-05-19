import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/player.dart';
import '../../services/fixture_service.dart';

class ExtraRoundConfigPage extends StatefulWidget {
  final int roundNumber;
  final List<Player> players;

  const ExtraRoundConfigPage({
    super.key,
    required this.roundNumber,
    required this.players,
  });

  @override
  State<ExtraRoundConfigPage> createState() => _ExtraRoundConfigPageState();
}

class _ExtraRoundConfigPageState extends State<ExtraRoundConfigPage> {
  final FixtureService _fixtureService = FixtureService();
  bool _isSaving = false;

  // Match 1
  Player? _match1Player1;
  Player? _match1Player2;

  // Match 2
  Player? _match2Player1;
  Player? _match2Player2;

  List<Player> get _playablePlayers =>
      widget.players.where((p) => p.name != 'BYE').toList();

  bool get _isValid {
    if (_match1Player1 == null ||
        _match1Player2 == null ||
        _match2Player1 == null ||
        _match2Player2 == null) {
      return false;
    }
    if (_match1Player1!.id == _match1Player2!.id) return false;
    if (_match2Player1!.id == _match2Player2!.id) return false;
    // All 4 must be different
    final ids = {
      _match1Player1!.id,
      _match1Player2!.id,
      _match2Player1!.id,
      _match2Player2!.id,
    };
    return ids.length == 4;
  }

  Future<void> _saveMatches() async {
    if (!_isValid) return;

    setState(() => _isSaving = true);

    try {
      await _fixtureService.addMatchesToRound(widget.roundNumber, [
        {
          'player1_name': _match1Player1!.name,
          'player2_name': _match1Player2!.name,
        },
        {
          'player1_name': _match2Player1!.name,
          'player2_name': _match2Player2!.name,
        },
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ronda ${widget.roundNumber} configurada correctamente',
            ),
            backgroundColor: AppColors.sageGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildMatchRow({
    required String label,
    required Player? player1,
    required Player? player2,
    required void Function(Player?) onPlayer1Changed,
    required void Function(Player?) onPlayer2Changed,
    Set<int> excludeIds = const {},
  }) {
    List<Player> available(Player? selected) => _playablePlayers
        .where((p) => p.id == selected?.id || !excludeIds.contains(p.id))
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Player>(
                    decoration: const InputDecoration(
                      labelText: 'Jugador 1',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    initialValue: player1,
                    items: available(player1)
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onPlayer1Changed,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'vs',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<Player>(
                    decoration: const InputDecoration(
                      labelText: 'Jugador 2',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    initialValue: player2,
                    items: available(player2)
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onPlayer2Changed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build exclusion sets so no player appears in two matches
    final match1Ids = {
      if (_match1Player1 != null) _match1Player1!.id,
      if (_match1Player2 != null) _match1Player2!.id,
    };
    final match2Ids = {
      if (_match2Player1 != null) _match2Player1!.id,
      if (_match2Player2 != null) _match2Player2!.id,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Ronda ${widget.roundNumber} — Extra'),
        actions: [
          TextButton.icon(
            onPressed: (_isValid && !_isSaving) ? _saveMatches : null,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.cloud_upload, color: AppColors.white),
            label: const Text(
              'Guardar',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.ocher.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.ocher.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.ocher, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Asigna los 4 jugadores de la ronda extra. '
                      'Los resultados contarán en el standings.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildMatchRow(
              label: 'Match 1',
              player1: _match1Player1,
              player2: _match1Player2,
              excludeIds: match2Ids,
              onPlayer1Changed: (p) => setState(() {
                _match1Player1 = p;
                if (_match1Player2?.id == p?.id) _match1Player2 = null;
              }),
              onPlayer2Changed: (p) => setState(() {
                _match1Player2 = p;
                if (_match1Player1?.id == p?.id) _match1Player1 = null;
              }),
            ),
            _buildMatchRow(
              label: 'Match 2',
              player1: _match2Player1,
              player2: _match2Player2,
              excludeIds: match1Ids,
              onPlayer1Changed: (p) => setState(() {
                _match2Player1 = p;
                if (_match2Player2?.id == p?.id) _match2Player2 = null;
              }),
              onPlayer2Changed: (p) => setState(() {
                _match2Player2 = p;
                if (_match2Player1?.id == p?.id) _match2Player1 = null;
              }),
            ),
            if (!_isValid && (_match1Player1 != null || _match2Player1 != null))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Los 4 jugadores deben ser distintos',
                  style: TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
