import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../controllers/online_tournament_controller.dart';
import '../../models/online_tournament.dart';

class OnlineTournamentStandingsPage extends StatefulWidget {
  final OnlineTournament tournament;

  const OnlineTournamentStandingsPage({super.key, required this.tournament});

  @override
  State<OnlineTournamentStandingsPage> createState() =>
      _OnlineTournamentStandingsPageState();
}

class _OnlineTournamentStandingsPageState
    extends State<OnlineTournamentStandingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnlineTournamentController>().loadTournamentStandings(
        widget.tournament.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnlineTournamentController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.standings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final standings = controller.standings;
        if (standings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.leaderboard,
                  size: 64,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No standings yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStandingsHeader(context),
            const SizedBox(height: 16),
            ...List.generate(standings.length, (index) {
              final standing = standings[index];
              return _buildStandingCard(context, standing, index + 1);
            }),
          ],
        );
      },
    );
  }

  Widget _buildStandingsHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.tournament.name} - Standings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Format: ${widget.tournament.format}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.sageGreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingCard(
    BuildContext context,
    dynamic standing,
    int position,
  ) {
    Color getPositionColor(int pos) {
      switch (pos) {
        case 1:
          return Colors.amber;
        case 2:
          return Colors.grey;
        case 3:
          return Colors.orange;
        default:
          return Colors.grey.shade400;
      }
    }

    final positionColor = getPositionColor(position);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: positionColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  position.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    standing.playerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatBadge('W: ${standing.wins}', Colors.green),
                      const SizedBox(width: 8),
                      _buildStatBadge('T: ${standing.ties}', Colors.orange),
                      const SizedBox(width: 8),
                      _buildStatBadge('L: ${standing.losses}', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${standing.points}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sageGreen,
                  ),
                ),
                Text(
                  '${standing.matchesPlayed} matches',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
