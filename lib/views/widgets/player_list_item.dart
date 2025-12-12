import 'package:flutter/material.dart';
import '../../models/player.dart';
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
          ],
        ),
      ),
    );
  }
}
