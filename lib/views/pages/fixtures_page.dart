import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/fixture_controller.dart';
import '../../controllers/player_controller.dart';
import '../../config/app_theme.dart';
import '../../models/fixture.dart';
import '../../models/player.dart';
import 'extra_round_config_page.dart';

class FixturesPage extends StatefulWidget {
  const FixturesPage({super.key});

  @override
  State<FixturesPage> createState() => _FixturesPageState();
}

class _FixturesPageState extends State<FixturesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FixtureController>().loadFixture();
      context.read<PlayerController>().loadPlayers();
    });
  }

  Future<void> _openExtraRoundEditor(
    BuildContext context,
    FixtureRound round,
    List<Player> players,
  ) async {
    final confirmedPlayers = players.where((p) => p.confirmed).toList();
    if (confirmedPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No confirmed players available yet.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final initialMatches = round.matches
        .map(
          (match) => {
            'player1_name': match.player1Name,
            'player2_name': match.player2Name,
          },
        )
        .toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExtraRoundConfigPage(
          roundNumber: round.number,
          players: confirmedPlayers,
          initialMatches: initialMatches,
        ),
      ),
    );

    if (context.mounted) {
      context.read<FixtureController>().loadFixture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FixtureController>().loadFixture();
            },
          ),
        ],
      ),
      body: Consumer2<FixtureController, PlayerController>(
        builder: (context, controller, playerController, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading fixture',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      controller.error!,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.loadFixture(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.fixture == null ||
              controller.fixture!.rounds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No fixture available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact admin to create a fixture',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadFixture(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.fixture!.rounds.length,
              itemBuilder: (context, index) {
                final round = controller.fixture!.rounds[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.sageGreen,
                          child: Text(
                            '${round.number}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Round ${round.number}'),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: round.format == 'PB'
                                    ? AppColors.petrolBlue.withValues(
                                        alpha: 0.2,
                                      )
                                    : AppColors.ocher.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                round.format,
                                style: TextStyle(
                                  color: round.format == 'PB'
                                      ? AppColors.petrolBlue
                                      : AppColors.ocher,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (round.subformat != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.sageGreen.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    round.subformat!,
                                    style: const TextStyle(
                                      color: AppColors.sageGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    children: [
                      ...round.matches.map((match) {
                        return ListTile(
                          leading: Icon(
                            match.completed
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: match.completed
                                ? AppColors.sageGreen
                                : AppColors.textSecondary,
                          ),
                          title: Text(
                            '${match.player1Name} vs ${match.player2Name}',
                          ),
                          subtitle: match.completed
                              ? Text(
                                  'Score: ${match.score1} - ${match.score2}',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : const Text('Pending'),
                        );
                      }),
                      if (round.isExtraRound)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: playerController.isLoading
                                  ? null
                                  : () => _openExtraRoundEditor(
                                      context,
                                      round,
                                      playerController.players,
                                    ),
                              icon: const Icon(Icons.edit),
                              label: Text(
                                round.matches.isEmpty
                                    ? 'Configurar ronda extra'
                                    : 'Editar ronda extra',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.petrolBlue,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
