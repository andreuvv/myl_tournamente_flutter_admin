import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match.dart';
import '../../controllers/match_controller.dart';
import '../../config/app_theme.dart';

class MatchResultCard extends StatelessWidget {
  final Match match;

  const MatchResultCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    // Determine if this is a bye match
    final isBye = match.isByeMatch;

    return Card(
      color: isBye ? AppColors.surface.withOpacity(0.7) : null,
      child: InkWell(
        onTap: () => _showEditDialog(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildPlayerInfo(
                      context,
                      match.player1Name,
                      match.score1,
                      match.winner == match.player1Name,
                      isBye: isBye,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          isBye ? 'BYE' : 'VS',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: isBye
                                    ? AppColors.ocher
                                    : AppColors.textSecondary,
                                fontWeight: isBye
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildPlayerInfo(
                      context,
                      match.player2Name,
                      match.score2,
                      match.winner == match.player2Name,
                      isPlayer2: true,
                      isBye: isBye,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _showEditDialog(context),
                icon: const Icon(Icons.edit),
                label: Text(match.completed ? 'Edit Result' : 'Enter Result'),
              ),
              if (match.isDraw) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ocher.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DRAW',
                    style: TextStyle(
                      color: AppColors.ocher,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              if (isBye && match.completed) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'BYE RECORDED',
                    style: TextStyle(
                      color: AppColors.sageGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(
    BuildContext context,
    String name,
    int? score,
    bool isWinner, {
    bool isPlayer2 = false,
    bool isBye = false,
  }) {
    final isByeName = name == 'BYE';

    return Column(
      crossAxisAlignment: isPlayer2
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: isWinner || isByeName
                ? FontWeight.bold
                : FontWeight.normal,
            color: isByeName
                ? AppColors.ocher
                : isWinner
                ? AppColors.sageGreen
                : AppColors.textPrimary,
          ),
          textAlign: isPlayer2 ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 4),
        Text(
          isByeName ? '—' : (score?.toString() ?? '-'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isByeName
                ? AppColors.textSecondary
                : isWinner
                ? AppColors.sageGreen
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _MatchResultDialog(match: match),
    );
  }
}

class _MatchResultDialog extends StatefulWidget {
  final Match match;

  const _MatchResultDialog({required this.match});

  @override
  State<_MatchResultDialog> createState() => _MatchResultDialogState();
}

class _MatchResultDialogState extends State<_MatchResultDialog> {
  late final TextEditingController _player1ScoreController;
  late final TextEditingController _player2ScoreController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player1ScoreController = TextEditingController(
      text: widget.match.score1?.toString() ?? '',
    );
    _player2ScoreController = TextEditingController(
      text: widget.match.score2?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _player1ScoreController.dispose();
    _player2ScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Match Result'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.match.player1Name} vs ${widget.match.player2Name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _player1ScoreController,
                  decoration: InputDecoration(
                    labelText: widget.match.player1Name,
                    hintText: 'Score',
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _player2ScoreController,
                  decoration: InputDecoration(
                    labelText: widget.match.player2Name,
                    hintText: 'Score',
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final score1 = int.tryParse(_player1ScoreController.text);
    final score2 = int.tryParse(_player2ScoreController.text);

    if (score1 == null || score2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid scores'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final controller = context.read<MatchController>();
    final success = await controller.updateMatchResult(
      widget.match.id,
      score1,
      score2,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match result updated successfully'),
            backgroundColor: AppColors.sageGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.error ?? 'Failed to update match result'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
