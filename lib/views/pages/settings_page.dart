import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/tournament_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TournamentService _tournamentService = TournamentService();
  bool _isLoading = false;

  Future<void> _clearTournament({required bool clearPlayers}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Clear'),
        content: Text(
          clearPlayers
              ? 'This will delete ALL tournament data including players, matches, and rounds. This cannot be undone!'
              : 'This will delete all matches and rounds, but keep players. This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _tournamentService.clearTournament(clearPlayers: clearPlayers);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              clearPlayers
                  ? 'Tournament data cleared (including players)'
                  : 'Tournament data cleared (players kept)',
            ),
            backgroundColor: AppColors.sageGreen,
          ),
        );
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
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _archiveTournament() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    String month = 'Enero';
    int year = DateTime.now().year;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Archive Tournament'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tournament Name',
                      hintText: 'e.g., Premier Mitológico',
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Name required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: month,
                    decoration: const InputDecoration(labelText: 'Month'),
                    items: months
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (value) =>
                        setDialogState(() => month = value ?? 'Enero'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Year'),
                    initialValue: year.toString(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final y = int.tryParse(value ?? '');
                      return y == null ? 'Invalid year' : null;
                    },
                    onChanged: (value) => year = int.tryParse(value) ?? year,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(
                      '${startDate.day}/${startDate.month}/${startDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setDialogState(() => startDate = date);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(
                      '${endDate.day}/${endDate.month}/${endDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setDialogState(() => endDate = date);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sageGreen,
              ),
              child: const Text('Archive'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Tournament name cannot be empty');
      }

      await _tournamentService.archiveTournament(
        name: name,
        month: month,
        year: year,
        startDate:
            '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
        endDate:
            '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament archived successfully!'),
            backgroundColor: AppColors.sageGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show full error in a dialog for better debugging
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Archive Failed'),
            content: SingleChildScrollView(child: SelectableText(e.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.archive, color: AppColors.sageGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Tournament Archive',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Save the current tournament data before clearing. This preserves all standings and match results for historical records.',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _archiveTournament,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.archive),
                      label: const Text('Archive Current Tournament'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sageGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppColors.ocher),
                      const SizedBox(width: 8),
                      Text(
                        'Danger Zone',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Clear tournament data to start fresh. Use with caution!',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => _clearTournament(clearPlayers: false),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_sweep),
                      label: const Text(
                        'Clear Matches & Rounds (Keep Players)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ocher,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
