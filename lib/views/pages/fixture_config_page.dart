import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/player_service.dart';
import '../../services/fixture_service.dart';
import '../../models/player.dart';

class FixtureConfigPage extends StatefulWidget {
  const FixtureConfigPage({super.key});

  @override
  State<FixtureConfigPage> createState() => _FixtureConfigPageState();
}

class _FixtureConfigPageState extends State<FixtureConfigPage> {
  final PlayerService _playerService = PlayerService();
  final FixtureService _fixtureService = FixtureService();

  List<Player> _confirmedPlayers = [];
  List<RoundConfig> _rounds = [];
  bool _isLoading = true;
  bool _isPosting = false;
  String? _error;

  String _formatMode = 'both'; // 'pb_only', 'bf_only', 'both'
  int _numberOfRounds = 5;

  @override
  void initState() {
    super.initState();
    _loadConfirmedPlayers();
  }

  Future<void> _loadConfirmedPlayers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final confirmed = await _playerService.getConfirmedPlayers();
      setState(() {
        _confirmedPlayers = confirmed;
        // Set default rounds to full round-robin cycle
        if (confirmed.length >= 2) {
          _numberOfRounds = confirmed.length % 2 == 0
              ? confirmed.length - 1
              : confirmed.length;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _generateFixture() {
    if (_confirmedPlayers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need at least 2 confirmed players'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final rounds = _generateRoundRobinFixture(
      _confirmedPlayers,
      _numberOfRounds,
    );

    setState(() {
      _rounds = rounds;
    });
  }

  /// Generates a round-robin tournament fixture
  /// Each player faces every other player exactly once per cycle
  /// If numberOfRounds exceeds one full cycle, it starts a new cycle
  List<RoundConfig> _generateRoundRobinFixture(
    List<Player> players,
    int numberOfRounds,
  ) {
    final rounds = <RoundConfig>[];
    final playerCount = players.length;

    // For round-robin, we need n-1 rounds for n players (or n rounds if n is even)
    final roundsPerCycle = playerCount % 2 == 0 ? playerCount - 1 : playerCount;

    // Shuffle players initially for randomization
    final shuffledPlayers = List<Player>.from(players)..shuffle(Random());

    // If odd number of players, add a dummy "bye" player
    final workingPlayers = playerCount % 2 == 0
        ? List<Player>.from(shuffledPlayers)
        : [...shuffledPlayers, Player(id: -1, name: 'BYE', confirmed: false)];

    final n = workingPlayers.length;

    for (int roundIndex = 0; roundIndex < numberOfRounds; roundIndex++) {
      final cycleRound = roundIndex % roundsPerCycle;

      String format;
      if (_formatMode == 'pb_only') {
        format = 'PB';
      } else if (_formatMode == 'bf_only') {
        format = 'BF';
      } else {
        // Alternate: PB first, then BF, then PB, etc.
        format = (roundIndex + 1) % 2 == 1 ? 'PB' : 'BF';
      }

      final matches = <MatchPairing>[];

      // Circle rotation algorithm
      // Fix the first player, rotate others
      for (int i = 0; i < n ~/ 2; i++) {
        int home = i;
        int away = n - 1 - i;

        // Apply rotation (keep position 0 fixed)
        if (home != 0) {
          home = ((home - cycleRound - 1) % (n - 1)) + 1;
        }
        if (away != 0) {
          away = ((away - cycleRound - 1) % (n - 1)) + 1;
        }

        final player1 = workingPlayers[home];
        final player2 = workingPlayers[away];

        // Include all matches, including BYE matches
        matches.add(MatchPairing(player1: player1, player2: player2));
      }

      rounds.add(
        RoundConfig(
          roundNumber: roundIndex + 1,
          format: format,
          matches: matches,
        ),
      );
    }

    return rounds;
  }

  Future<void> _postFixture() async {
    if (_rounds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generate fixture first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      // Build fixture request
      final fixtureData = {
        'players': _confirmedPlayers
            .map((p) => {'name': p.name, 'confirmed': p.confirmed})
            .toList(),
        'rounds': _rounds
            .map(
              (r) => {
                'round_number': r.roundNumber,
                'format': r.format,
                'matches': r.matches
                    .map(
                      (m) => {
                        'player1_name': m.player1.name,
                        'player2_name': m.player2.name,
                      },
                    )
                    .toList(),
              },
            )
            .toList(),
      };

      await _fixtureService.createFixture(fixtureData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fixture created successfully!'),
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
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configure Fixture')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Configure Fixture')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadConfirmedPlayers,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Fixture'),
        actions: [
          if (_rounds.isNotEmpty)
            TextButton.icon(
              onPressed: _isPosting ? null : _postFixture,
              icon: _isPosting
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
                'Post Fixture',
                style: TextStyle(color: AppColors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Configuration section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirmed Players: ${_confirmedPlayers.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Format Mode',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'pb_only', label: Text('PB Only')),
                    ButtonSegment(value: 'bf_only', label: Text('BF Only')),
                    ButtonSegment(
                      value: 'both',
                      label: Text('Both (Alternate)'),
                    ),
                  ],
                  selected: {_formatMode},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _formatMode = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Number of Rounds: $_numberOfRounds',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (_confirmedPlayers.length >= 2) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Full cycle: ${_confirmedPlayers.length % 2 == 0 ? _confirmedPlayers.length - 1 : _confirmedPlayers.length} rounds (each player vs all others once)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                Slider(
                  value: _numberOfRounds.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _numberOfRounds.toString(),
                  onChanged: (value) {
                    setState(() {
                      _numberOfRounds = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generateFixture,
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Generate Fixture'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Preview section
          Expanded(
            child: _rounds.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No fixture generated yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Configure settings and click Generate',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rounds.length,
                    itemBuilder: (context, index) {
                      final round = _rounds[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text('Round ${round.roundNumber}'),
                          subtitle: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: round.format == 'BF'
                                      ? AppColors.petrolBlue
                                      : AppColors.sageGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  round.format,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${round.matches.length} matches'),
                            ],
                          ),
                          children: round.matches.map((match) {
                            final isBye =
                                match.player1.name == 'BYE' ||
                                match.player2.name == 'BYE';
                            return ListTile(
                              dense: true,
                              title: Text(
                                isBye
                                    ? '${match.player1.name == 'BYE' ? match.player2.name : match.player1.name} (BYE)'
                                    : '${match.player1.name} vs ${match.player2.name}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isBye
                                      ? Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color
                                      : null,
                                  fontStyle: isBye
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class RoundConfig {
  final int roundNumber;
  final String format;
  final List<MatchPairing> matches;

  RoundConfig({
    required this.roundNumber,
    required this.format,
    required this.matches,
  });
}

class MatchPairing {
  final Player player1;
  final Player player2;

  MatchPairing({required this.player1, required this.player2});
}
