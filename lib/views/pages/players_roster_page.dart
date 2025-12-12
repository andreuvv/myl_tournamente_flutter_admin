import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/player_service.dart';
import '../../models/player.dart';

class PlayersRosterPage extends StatefulWidget {
  const PlayersRosterPage({super.key});

  @override
  State<PlayersRosterPage> createState() => _PlayersRosterPageState();
}

class _PlayersRosterPageState extends State<PlayersRosterPage> {
  final PlayerService _playerService = PlayerService();
  List<Player> _players = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final players = await _playerService.getPlayers();
      setState(() {
        _players = players;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading players: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _toggleConfirmed(Player player) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final updatedPlayer = await _playerService.togglePlayerConfirmed(
        player.id,
      );
      setState(() {
        final index = _players.indexWhere((p) => p.id == player.id);
        if (index != -1) {
          _players[index] = updatedPlayer;
        }
        _isProcessing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final confirmedCount = _players.where((p) => p.confirmed).length;
    final unconfirmedCount = _players.length - confirmedCount;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Players Roster'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadPlayers,
            ),
          ],
        ),
        body: Column(
          children: [
            // Stats section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Total',
                    _players.length.toString(),
                    AppColors.petrolBlue,
                  ),
                  _buildStatCard(
                    'Confirmed',
                    confirmedCount.toString(),
                    AppColors.sageGreen,
                  ),
                  _buildStatCard(
                    'Unconfirmed',
                    unconfirmedCount.toString(),
                    AppColors.ocher,
                  ),
                ],
              ),
            ),
            // Players list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _players.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No players in roster',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add players to get started',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _players.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: player.confirmed
                                  ? AppColors.sageGreen
                                  : AppColors.ocher,
                              child: Text(
                                player.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              player.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  player.confirmed
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 16,
                                  color: player.confirmed
                                      ? AppColors.sageGreen
                                      : AppColors.ocher,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  player.confirmed
                                      ? 'Confirmed'
                                      : 'Not confirmed',
                                  style: TextStyle(
                                    color: player.confirmed
                                        ? AppColors.sageGreen
                                        : AppColors.ocher,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    player.confirmed
                                        ? Icons.toggle_on
                                        : Icons.toggle_off,
                                    size: 32,
                                  ),
                                  color: player.confirmed
                                      ? AppColors.sageGreen
                                      : AppColors.textSecondary,
                                  onPressed: _isProcessing
                                      ? null
                                      : () => _toggleConfirmed(player),
                                  tooltip: 'Toggle confirmation',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
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
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
