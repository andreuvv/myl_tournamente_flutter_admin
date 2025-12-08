import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/player_service.dart';

class PlayerManagementPage extends StatefulWidget {
  const PlayerManagementPage({super.key});

  @override
  State<PlayerManagementPage> createState() => _PlayerManagementPageState();
}

class _PlayerManagementPageState extends State<PlayerManagementPage> {
  final List<PlayerEntry> _players = [];
  final TextEditingController _nameController = TextEditingController();
  final PlayerService _playerService = PlayerService();
  bool _isPosting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _players.add(PlayerEntry(name: name, confirmed: false));
        _nameController.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _toggleConfirmed(int index) {
    setState(() {
      _players[index].confirmed = !_players[index].confirmed;
    });
  }

  Future<void> _postAllPlayers() async {
    final confirmedPlayers = _players.where((p) => p.confirmed).toList();

    if (confirmedPlayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No confirmed players to add'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      int successCount = 0;
      for (final player in confirmedPlayers) {
        await _playerService.createPlayer(player.name, player.confirmed);
        successCount++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added $successCount confirmed players'),
            backgroundColor: AppColors.sageGreen,
          ),
        );
        setState(() {
          _players.removeWhere((p) => p.confirmed);
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Players'),
        actions: [
          if (_players.isNotEmpty)
            TextButton.icon(
              onPressed: _isPosting ? null : _postAllPlayers,
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
              label: Text(
                'Post Confirmed (${_players.where((p) => p.confirmed).length})',
                style: const TextStyle(color: AppColors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Input section
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter player name',
                      prefixIcon: Icon(Icons.person_add),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addPlayer,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Players list
          Expanded(
            child: _players.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No players added yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add players above to get started',
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
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: player.confirmed
                                ? AppColors.sageGreen
                                : AppColors.textSecondary,
                            child: Text(
                              player.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(player.name),
                          subtitle: Text(
                            player.confirmed ? 'Confirmed' : 'Not confirmed',
                            style: TextStyle(
                              color: player.confirmed
                                  ? AppColors.sageGreen
                                  : AppColors.textSecondary,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: player.confirmed,
                                onChanged: (_) => _toggleConfirmed(index),
                                activeColor: AppColors.sageGreen,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: AppColors.error,
                                onPressed: () => _removePlayer(index),
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
    );
  }
}

class PlayerEntry {
  final String name;
  bool confirmed;

  PlayerEntry({required this.name, required this.confirmed});
}
