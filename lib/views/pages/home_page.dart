import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_theme.dart';
import 'settings_page.dart';
import 'player_management_page.dart';
import 'fixture_config_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePageContent();
  }
}

class HomePageContent extends StatelessWidget {
  final Function(int)? onNavigate;

  const HomePageContent({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.coalGrey, AppColors.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'lib/assets/logo_app(1).svg',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'MYL Tournament',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Admin Panel',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.sageGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  _buildMenuGrid(context),
                  const SizedBox(height: 48),
                  Text(
                    'Manage your tournament with ease',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMenuCard(
          context,
          icon: Icons.people,
          title: 'Players',
          description: 'Manage tournament players',
          color: AppColors.sageGreen,
          index: 1,
        ),
        _buildMenuCard(
          context,
          icon: Icons.event_note,
          title: 'Fixture',
          description: 'View tournament fixture',
          color: AppColors.petrolBlue,
          index: 2,
        ),
        _buildMenuCard(
          context,
          icon: Icons.leaderboard,
          title: 'Standings',
          description: 'View current standings',
          color: AppColors.ocher,
          index: 3,
        ),
        _buildMenuCard(
          context,
          icon: Icons.sports_esports,
          title: 'Matches',
          description: 'Update match results',
          color: AppColors.brickRed,
          index: 4,
        ),
        _buildMenuCard(
          context,
          icon: Icons.group_add,
          title: 'Create Players',
          description: 'Batch add players',
          color: AppColors.sageGreen.withOpacity(0.8),
          isCustomRoute: true,
          customRoute: const PlayerManagementPage(),
        ),
        _buildMenuCard(
          context,
          icon: Icons.shuffle,
          title: 'Config Fixture',
          description: 'Generate tournament fixture',
          color: AppColors.petrolBlue.withOpacity(0.8),
          isCustomRoute: true,
          customRoute: const FixtureConfigPage(),
        ),
        _buildMenuCard(
          context,
          icon: Icons.settings,
          title: 'Settings',
          description: 'Clear tournament data',
          color: AppColors.error,
          isSettings: true,
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    int? index,
    bool isSettings = false,
    bool isCustomRoute = false,
    Widget? customRoute,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          if (isSettings) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          } else if (isCustomRoute && customRoute != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => customRoute),
            );
          } else if (onNavigate != null && index != null) {
            onNavigate!(index);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
