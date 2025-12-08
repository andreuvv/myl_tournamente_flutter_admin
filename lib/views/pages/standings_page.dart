import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/standings_controller.dart';
import '../../config/app_theme.dart';

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StandingsController>().loadStandings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StandingsController>().loadStandings();
            },
          ),
        ],
      ),
      body: Consumer<StandingsController>(
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
                    'Error loading standings',
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
                    onPressed: () => controller.loadStandings(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.standings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.leaderboard_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No standings yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete some matches to see standings',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadStandings(),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      AppColors.surface,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith<Color>(
                      (states) => states.contains(MaterialState.selected)
                          ? AppColors.sageGreen.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          '#',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Player',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'MP',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'W',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'T',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'L',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Pts',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'GF',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'Win %',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        numeric: true,
                      ),
                    ],
                    rows: controller.standings.asMap().entries.map((entry) {
                      final index = entry.key;
                      final standing = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(_buildPositionCell(index + 1)),
                          DataCell(Text(standing.name)),
                          DataCell(Text(standing.matchesPlayed.toString())),
                          DataCell(Text(standing.wins.toString())),
                          DataCell(Text(standing.ties.toString())),
                          DataCell(Text(standing.losses.toString())),
                          DataCell(
                            Text(
                              standing.points.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.sageGreen,
                              ),
                            ),
                          ),
                          DataCell(Text(standing.totalPointsScored.toString())),
                          DataCell(
                            Text(
                              '${(standing.winRate * 100).toStringAsFixed(1)}%',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPositionCell(int position) {
    Color? backgroundColor;
    if (position == 1) {
      backgroundColor = AppColors.ocher;
    } else if (position == 2) {
      backgroundColor = AppColors.sageGreen;
    } else if (position == 3) {
      backgroundColor = AppColors.petrolBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Text(
        position.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: backgroundColor != null
              ? AppColors.white
              : AppColors.textPrimary,
        ),
      ),
    );
  }
}
