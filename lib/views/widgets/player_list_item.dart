import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player.dart';
import '../../controllers/player_controller.dart';
import '../../config/app_theme.dart';

class PlayerListItem extends StatelessWidget {
  final Player player;

  const PlayerListItem({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.sageGreen,
          child: Text(
            player.name.substring(0, 1).toUpperCase(),
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
            if (player.confirmed)
              const Icon(
                Icons.check_circle,
                color: AppColors.sageGreen,
                size: 20,
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete ${player.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final controller = context.read<PlayerController>();
              final success = await controller.deletePlayer(player.id);
              if (context.mounted) {
                Navigator.pop(context);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        controller.error ?? 'Failed to delete player',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
