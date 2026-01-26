import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../controllers/online_tournament_controller.dart';
import '../../models/player.dart';
import 'online_tournament_matches_page.dart';

class OnlineTournamentConfigPage extends StatefulWidget {
  const OnlineTournamentConfigPage({super.key});

  @override
  State<OnlineTournamentConfigPage> createState() =>
      _OnlineTournamentConfigPageState();
}

class _OnlineTournamentConfigPageState extends State<OnlineTournamentConfigPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  late TabController _tabController;
  String _selectedFormat = 'PB';
  Set<int> _selectedPlayerIds = {};
  bool _isCreating = false;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<int> _years = List.generate(
    10,
    (index) => DateTime.now().year + index,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _monthController.text = _months[DateTime.now().month - 1];
    _yearController.text = DateTime.now().year.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnlineTournamentController>().loadPremierPlayers();
      context.read<OnlineTournamentController>().loadActiveTournaments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _createTournament() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter tournament name')),
      );
      return;
    }

    if (_selectedPlayerIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 players')),
      );
      return;
    }

    setState(() => _isCreating = true);

    final tournament = await context
        .read<OnlineTournamentController>()
        .createOnlineTournament(
          name: _nameController.text,
          month: _monthController.text,
          year: int.parse(_yearController.text),
          format: _selectedFormat,
          playerIds: _selectedPlayerIds.toList(),
          startDate: _startDateController.text.isNotEmpty
              ? _startDateController.text
              : null,
          endDate: _endDateController.text.isNotEmpty
              ? _endDateController.text
              : null,
        );

    setState(() => _isCreating = false);

    if (tournament != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tournament created: ${_selectedPlayerIds.length} players, ${_selectedPlayerIds.length * (_selectedPlayerIds.length - 1) ~/ 2} matches generated',
            ),
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                OnlineTournamentMatchesPage(tournament: tournament),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<OnlineTournamentController>().error ??
                  'Failed to create tournament',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Tournament'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Create New'),
            Tab(text: 'Active'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_buildCreateTab(), _buildActiveTab()],
        ),
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTournamentInfo(),
          const SizedBox(height: 32),
          _buildFormatSelection(),
          const SizedBox(height: 32),
          _buildPlayerSelection(),
          const SizedBox(height: 32),
          _buildCreateButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    return Consumer<OnlineTournamentController>(
      builder: (context, controller, _) {
        if (controller.activeTournaments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No active tournaments',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create One'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activeTournaments.length,
          itemBuilder: (context, index) {
            final tournament = controller.activeTournaments[index];
            return Card(
              child: ListTile(
                title: Text(tournament.name),
                subtitle: Text('${tournament.month} ${tournament.year}'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          OnlineTournamentMatchesPage(tournament: tournament),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTournamentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tournament Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tournament Name',
                hintText: 'e.g., January Online Tournament',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _monthController.text,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _monthController.text = value;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _yearController.text,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _years.map((year) {
                      return DropdownMenuItem(
                        value: year.toString(),
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _yearController.text = value;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(_startDateController),
                    child: TextField(
                      controller: _startDateController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Start Date (Optional)',
                        hintText: 'YYYY-MM-DD',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(_endDateController),
                    child: TextField(
                      controller: _endDateController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'End Date (Optional)',
                        hintText: 'YYYY-MM-DD',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
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

  Widget _buildFormatSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tournament Format',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFormatButton('PB', _selectedFormat == 'PB'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormatButton('BF', _selectedFormat == 'BF'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'All matches will use the selected format',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatButton(String format, bool isSelected) {
    return OutlinedButton(
      onPressed: () => setState(() => _selectedFormat = format),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.sageGreen : Colors.transparent,
        side: BorderSide(
          color: isSelected ? AppColors.sageGreen : AppColors.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        format,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPlayerSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Players',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedPlayerIds.length} selected',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<OnlineTournamentController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final players = controller.premierPlayers;
                if (players.isEmpty) {
                  return const Center(child: Text('No players available'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isSelected = _selectedPlayerIds.contains(player.id);

                    return CheckboxListTile(
                      title: Text(player.name),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedPlayerIds.add(player.id);
                          } else {
                            _selectedPlayerIds.remove(player.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Total matches to be created: ${_selectedPlayerIds.isEmpty ? 0 : _selectedPlayerIds.length * (_selectedPlayerIds.length - 1) ~/ 2}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.sageGreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreating ? null : _createTournament,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sageGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isCreating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Create Tournament',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
