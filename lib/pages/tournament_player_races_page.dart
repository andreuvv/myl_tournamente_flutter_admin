import 'package:flutter/material.dart';
import 'package:myl_tournament_admin/config/app_theme.dart';
import 'package:provider/provider.dart';
import '../controllers/tournament_race_controller.dart';
import '../models/tournament.dart';

class TournamentPlayerRacesPage extends StatefulWidget {
  const TournamentPlayerRacesPage({super.key});

  @override
  State<TournamentPlayerRacesPage> createState() =>
      _TournamentPlayerRacesPageState();
}

class _TournamentPlayerRacesPageState extends State<TournamentPlayerRacesPage> {
  @override
  void initState() {
    super.initState();
    // Load tournaments when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentRaceController>().loadArchivedTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrera del Torneo'), elevation: 0),
      body: Consumer<TournamentRaceController>(
        builder: (context, controller, child) {
          // Show tournament list if no tournament selected
          if (controller.selectedTournament == null) {
            return _buildTournamentsList(context, controller);
          }

          // Show player list for selected tournament
          return _buildPlayersList(context, controller);
        },
      ),
    );
  }

  Widget _buildTournamentsList(
    BuildContext context,
    TournamentRaceController controller,
  ) {
    if (controller.isLoadingTournaments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.tournaments.isEmpty) {
      return const Center(child: Text('No archived tournaments found'));
    }

    return ListView.builder(
      itemCount: controller.tournaments.length,
      itemBuilder: (context, index) {
        final tournament = controller.tournaments[index];
        return ListTile(
          title: Text(tournament.name),
          subtitle: Text('${tournament.month} ${tournament.year}'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            controller.loadTournamentPlayers(tournament);
          },
        );
      },
    );
  }

  Widget _buildPlayersList(
    BuildContext context,
    TournamentRaceController controller,
  ) {
    return Column(
      children: [
        // Back button and tournament title
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  controller.clearSelection();
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.selectedTournament?.name ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${controller.selectedTournament?.month} ${controller.selectedTournament?.year}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Players list
        Expanded(child: _buildPlayersListBody(context, controller)),
      ],
    );
  }

  Widget _buildPlayersListBody(
    BuildContext context,
    TournamentRaceController controller,
  ) {
    if (controller.isLoadingPlayers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.selectedTournamentPlayers.isEmpty) {
      return const Center(child: Text('No players found in this tournament'));
    }

    return ListView.builder(
      itemCount: controller.selectedTournamentPlayers.length,
      itemBuilder: (context, index) {
        final player = controller.selectedTournamentPlayers[index];
        final raceData = controller.getOrCreatePlayerRace(player);

        return PlayerRaceListTile(
          player: player,
          raceData: raceData,
          onTap: () {
            _showRaceSelectionModal(context, player, controller);
          },
        );
      },
    );
  }

  void _showRaceSelectionModal(
    BuildContext context,
    TournamentPlayer player,
    TournamentRaceController controller,
  ) {
    final raceData = controller.getOrCreatePlayerRace(player);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => RaceSelectionModal(
        player: player,
        initialRaceData: raceData,
        onSave: (racePb, raceBf, notes) async {
          final success = await controller.savePlayerRace(
            player.id,
            racePb,
            raceBf,
            notes,
          );

          if (mounted && success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Race data saved successfully')),
            );
          } else if (mounted && !success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${controller.errorMessage}')),
            );
          }
        },
      ),
    );
  }
}

class PlayerRaceListTile extends StatelessWidget {
  final TournamentPlayer player;
  final PlayerRace raceData;
  final VoidCallback onTap;

  const PlayerRaceListTile({
    Key? key,
    required this.player,
    required this.raceData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(player.name),
      subtitle: Row(
        children: [
          if (raceData.racePb != null)
            Chip(
              label: Text('PB: ${raceData.racePb}', style: const TextStyle(color: AppColors.coalGrey)),
              backgroundColor: AppColors.petrolBlue,
              labelStyle: const TextStyle(fontSize: 11),
            ),
          const SizedBox(width: 4),
          if (raceData.raceBf != null)
            Chip(
              label: Text('BF: ${raceData.raceBf}', style: const TextStyle(color: AppColors.coalGrey)),
              backgroundColor: AppColors.sageGreen,
              labelStyle: const TextStyle(fontSize: 11),
            ),
        ],
      ),
      trailing: Icon(
        raceData.racePb != null || raceData.raceBf != null
            ? Icons.check_circle
            : Icons.edit,
        color: raceData.racePb != null || raceData.raceBf != null
            ? Colors.green
            : Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

class RaceSelectionModal extends StatefulWidget {
  final TournamentPlayer player;
  final PlayerRace initialRaceData;
  final Function(String?, String?, String?) onSave;

  const RaceSelectionModal({
    Key? key,
    required this.player,
    required this.initialRaceData,
    required this.onSave,
  }) : super(key: key);

  @override
  State<RaceSelectionModal> createState() => _RaceSelectionModalState();
}

class _RaceSelectionModalState extends State<RaceSelectionModal> {
  late String? selectedRacePb;
  late String? selectedRaceBf;
  late TextEditingController notesController;
  late TournamentRaceController controller;
  bool isSaving = false;

  final List<String> pbRaceOptions = [
    'Caballero',
    'Faerie',
    'Dragón',
    'Olímpico',
    'Titán',
    'Héroe',
    'Defensor',
    'Desafiante',
    'Sombra',
    'Sacerdote',
    'Faraón',
    'Eterno',
    'Tótem',
  ];

  final List<String> bfRaceOptions = [
    'Caballero',
    'Guerrero',
    'Eterno',
    'Sombra',
    'Dragón',
    'Bestia',
    'Sacerdote',
    'Ancestral',
    'Héroe',
    'Bárbaro',
    'Tótem',
  ];

  @override
  void initState() {
    super.initState();
    selectedRacePb = widget.initialRaceData.racePb;
    selectedRaceBf = widget.initialRaceData.raceBf;
    notesController = TextEditingController(
      text: widget.initialRaceData.notes ?? '',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = context.read<TournamentRaceController>();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Player info
              Text(
                widget.player.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // PB Race selection
              Text(
                '¿Qué raza jugó en PB?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButton<String?>(
                isExpanded: true,
                value: selectedRacePb,
                hint: const Text('Select race'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No data'),
                  ),
                  ...pbRaceOptions.map(
                    (race) => DropdownMenuItem<String?>(
                      value: race,
                      child: Text(race),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRacePb = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // BF Race selection
              Text(
                '¿Qué raza jugó en BF?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButton<String?>(
                isExpanded: true,
                value: selectedRaceBf,
                hint: const Text('Select race'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No data'),
                  ),
                  ...bfRaceOptions.map(
                    (race) => DropdownMenuItem<String?>(
                      value: race,
                      child: Text(race),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRaceBf = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Notes field
              Text(
                'Notas (opcional)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Agregar notas aquí...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() {
                            isSaving = true;
                          });

                          await widget.onSave(
                            selectedRacePb,
                            selectedRaceBf,
                            notesController.text.isEmpty
                                ? null
                                : notesController.text,
                          );

                          if (mounted) {
                            setState(() {
                              isSaving = false;
                            });
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
