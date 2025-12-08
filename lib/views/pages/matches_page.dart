import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/match_controller.dart';
import '../../config/app_theme.dart';
import '../widgets/match_result_card.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchController>().loadAllMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MatchController>().loadAllMatches();
            },
          ),
        ],
      ),
      body: Consumer<MatchController>(
        builder: (context, controller, child) {
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
                    'Error loading matches',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.loadAllMatches(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_esports_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No matches yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a fixture to generate matches',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          // Group matches by round number
          final matchesByRound = <int, List<dynamic>>{};
          for (final match in controller.matches) {
            if (!matchesByRound.containsKey(match.roundNumber)) {
              matchesByRound[match.roundNumber] = [];
            }
            matchesByRound[match.roundNumber]!.add(match);
          }

          // Sort rounds
          final sortedRounds = matchesByRound.keys.toList()..sort();

          return RefreshIndicator(
            onRefresh: () => controller.loadAllMatches(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...sortedRounds.map((roundNumber) {
                  final roundMatches = matchesByRound[roundNumber]!;
                  final pendingCount = roundMatches
                      .where((m) => !m.completed)
                      .length;
                  final completedCount = roundMatches
                      .where((m) => m.completed)
                      .length;
                  final format = roundMatches.isNotEmpty
                      ? roundMatches.first.format
                      : '';
                  // Expand rounds with incomplete matches by default
                  final hasIncomplete = roundMatches.any((m) => !m.completed);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 2,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: PageStorageKey<int>(roundNumber),
                          initiallyExpanded: hasIncomplete,
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          childrenPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          backgroundColor: AppColors.surface,
                          collapsedBackgroundColor: AppColors.surface,
                          title: Row(
                            children: [
                              Text(
                                'Round $roundNumber',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: format == 'BF'
                                      ? AppColors.petrolBlue
                                      : AppColors.sageGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  format,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              pendingCount > 0
                                  ? '$pendingCount pending • $completedCount/${roundMatches.length} complete'
                                  : 'All matches completed ($completedCount/${roundMatches.length})',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: pendingCount > 0
                                        ? AppColors.ocher
                                        : AppColors.sageGreen,
                                  ),
                            ),
                          ),
                          children: [
                            ...roundMatches.map(
                              (match) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: MatchResultCard(match: match),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
