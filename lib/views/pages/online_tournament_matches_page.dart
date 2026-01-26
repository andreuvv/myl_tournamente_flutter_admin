import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../controllers/online_tournament_controller.dart';
import '../../models/online_tournament.dart';
import 'online_tournament_standings_page.dart';

class OnlineTournamentMatchesPage extends StatefulWidget {
  final OnlineTournament tournament;

  const OnlineTournamentMatchesPage({super.key, required this.tournament});

  @override
  State<OnlineTournamentMatchesPage> createState() =>
      _OnlineTournamentMatchesPageState();
}

class _OnlineTournamentMatchesPageState
    extends State<OnlineTournamentMatchesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _autoRefresh = true;
  String? _selectedPlayerFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnlineTournamentController>().loadTournamentMatches(
        widget.tournament.id,
      );
      context.read<OnlineTournamentController>().loadTournamentStandings(
        widget.tournament.id,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Matches'),
            Tab(text: 'Standings'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OnlineTournamentController>().loadTournamentMatches(
                widget.tournament.id,
              );
              context
                  .read<OnlineTournamentController>()
                  .loadTournamentStandings(widget.tournament.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMatchesTab(),
            OnlineTournamentStandingsPage(tournament: widget.tournament),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesTab() {
    return Consumer<OnlineTournamentController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get all unique player names from matches
        final Set<String> playerNames = {};
        for (var match in controller.pendingMatches) {
          playerNames.add(match.player1Name);
          playerNames.add(match.player2Name);
        }
        for (var match in controller.completedMatches) {
          playerNames.add(match.player1Name);
          playerNames.add(match.player2Name);
        }
        final sortedPlayers = playerNames.toList()..sort();

        // Filter matches based on selected player
        final filteredPending = _selectedPlayerFilter == null
            ? controller.pendingMatches
            : controller.pendingMatches
                  .where(
                    (m) =>
                        m.player1Name == _selectedPlayerFilter ||
                        m.player2Name == _selectedPlayerFilter,
                  )
                  .toList();

        final filteredCompleted = _selectedPlayerFilter == null
            ? controller.completedMatches
            : controller.completedMatches
                  .where(
                    (m) =>
                        m.player1Name == _selectedPlayerFilter ||
                        m.player2Name == _selectedPlayerFilter,
                  )
                  .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatsCard(controller),
              const SizedBox(height: 16),
              _buildPlayerFilter(sortedPlayers),
              const SizedBox(height: 24),
              _buildMatchesSection('Pending Matches', filteredPending, true),
              const SizedBox(height: 24),
              _buildMatchesSection(
                'Completed Matches',
                filteredCompleted,
                false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerFilter(List<String> players) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Player',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButton<String?>(
              isExpanded: true,
              value: _selectedPlayerFilter,
              hint: const Text('All Players'),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: const Text('All Players'),
                ),
                ...players
                    .map(
                      (player) => DropdownMenuItem<String?>(
                        value: player,
                        child: Text(player),
                      ),
                    )
                    .toList(),
              ],
              onChanged: (value) {
                setState(() => _selectedPlayerFilter = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(OnlineTournamentController controller) {
    final pending = controller.pendingMatches.length;
    final completed = controller.completedMatches.length;
    final total = pending + completed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn('Total', total.toString(), AppColors.sageGreen),
            _buildStatColumn('Pending', pending.toString(), Colors.orange),
            _buildStatColumn('Completed', completed.toString(), Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildMatchesSection(String title, List matches, bool isPending) {
    if (matches.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                isPending ? Icons.schedule : Icons.check_circle,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                'No $title yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: matches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final match = matches[index];
            return _buildMatchCard(context, match, isPending);
          },
        ),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, dynamic match, bool isPending) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.player1Name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('vs', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        match.player2Name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    match.completed &&
                            match.score1 != null &&
                            match.score2 != null
                        ? '${match.score1} - ${match.score2}'
                        : '-',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (isPending)
              Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showScoreDialog(context, match),
                      icon: const Icon(Icons.edit),
                      label: const Text('Report Score'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sageGreen,
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showScoreDialog(BuildContext context, dynamic match) {
    final score1Controller = TextEditingController(
      text: match.score1?.toString() ?? '',
    );
    final score2Controller = TextEditingController(
      text: match.score2?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${match.player1Name} vs ${match.player2Name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: score1Controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: match.player1Name,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('-', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: score2Controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: match.player2Name,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final score1 = int.tryParse(score1Controller.text);
              final score2 = int.tryParse(score2Controller.text);

              if (score1 == null || score2 == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid scores')),
                );
                return;
              }

              await context.read<OnlineTournamentController>().updateMatchScore(
                match.id,
                score1,
                score2,
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Score updated!')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sageGreen,
            ),
            child: const Text('Save Score'),
          ),
        ],
      ),
    );
  }
}
