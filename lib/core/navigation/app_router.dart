import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/algorithm_arena_page.dart';
import '../../features/worlds/presentation/pages/worlds_page.dart';
import '../../features/worlds/presentation/pages/stack_temple_page.dart';
import '../../features/worlds/presentation/pages/queue_station_page.dart';
import '../../features/worlds/presentation/pages/treasure_hunt_page.dart';
import '../../features/worlds/presentation/pages/boss_level_page.dart';
import '../../features/worlds/presentation/pages/reflection_page.dart';
import '../../features/worlds/presentation/pages/reveal_theory_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../theme/gaming_colors.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: <RouteBase>[
    // Main App Shell with Bottom Navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: '/worlds',
          builder: (BuildContext context, GoRouterState state) {
            return const WorldsPage();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfilePage();
          },
        ),
      ],
    ),

    // Full Screen Game/Arena Routes (No navigation bar visible)
    GoRoute(
      path: '/arena',
      builder: (BuildContext context, GoRouterState state) {
        return const AlgorithmArenaPage();
      },
    ),
    GoRoute(
      path: '/game/level_1',
      builder: (BuildContext context, GoRouterState state) {
        return const StackTemplePage();
      },
    ),
    GoRoute(
      path: '/game/level_2',
      builder: (BuildContext context, GoRouterState state) {
        return const QueueStationPage();
      },
    ),
    GoRoute(
      path: '/game/level_3',
      builder: (BuildContext context, GoRouterState state) {
        return const TreasureHuntPage();
      },
    ),
    GoRoute(
      path: '/game/boss',
      builder: (BuildContext context, GoRouterState state) {
        return const BossLevelPage();
      },
    ),
    GoRoute(
      path: '/reflection/:gameId',
      builder: (BuildContext context, GoRouterState state) {
        final gameId = state.pathParameters['gameId'] ?? 'level_1';
        return ReflectionPage(gameId: gameId);
      },
    ),
    GoRoute(
      path: '/reveal',
      builder: (BuildContext context, GoRouterState state) {
        return const RevealTheoryPage();
      },
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_outlined),
            activeIcon: Icon(Icons.videogame_asset, color: GamingColors.primary),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore, color: GamingColors.primary),
            label: 'Worlds',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: GamingColors.primary),
            label: 'Profile',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/worlds')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/worlds');
        break;
      case 2:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
