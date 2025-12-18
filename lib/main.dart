import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_theme.dart';
import 'controllers/player_controller.dart';
import 'controllers/fixture_controller.dart';
import 'controllers/match_controller.dart';
import 'controllers/standings_controller.dart';
import 'controllers/tournament_race_controller.dart';
import 'views/pages/home_page.dart' as home;
import 'views/pages/players_page.dart';
import 'views/pages/fixtures_page.dart';
import 'views/pages/standings_page.dart';
import 'views/pages/matches_page.dart';
import 'pages/tournament_player_races_page.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerController()),
        ChangeNotifierProvider(create: (_) => FixtureController()),
        ChangeNotifierProvider(create: (_) => MatchController()),
        ChangeNotifierProvider(create: (_) => StandingsController()),
        ChangeNotifierProvider(create: (_) => TournamentRaceController()),
      ],
      child: MaterialApp(
        title: 'MYL Tournament Admin',
        theme: AppTheme.theme,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    home.HomePage(),
    PlayersPage(),
    FixturesPage(),
    StandingsPage(),
    MatchesPage(),
  ];

  void navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? home.HomePageContent(onNavigate: navigateToIndex)
          : _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.sageGreen.withOpacity(0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Players',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Fixture',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Standings',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Matches',
          ),
        ],
      ),
    );
  }
}
