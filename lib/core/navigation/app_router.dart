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
import '../../features/worlds/presentation/pages/play_launcher_page.dart';
import '../../features/home/presentation/pages/shop_page.dart';
import '../../features/home/presentation/pages/arena_challenge_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../theme/gaming_colors.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: <RouteBase>[
    // Main App Shell with Bottom Navigation (5 Tabs)
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
      path: '/arena/challenge',
      builder: (BuildContext context, GoRouterState state) {
        return const ArenaChallengePage();
      },
    ),
    GoRoute(
      path: '/play',
      builder: (BuildContext context, GoRouterState state) {
        return const PlayLauncherPage();
      },
    ),
    GoRoute(
      path: '/shop',
      builder: (BuildContext context, GoRouterState state) {
        return const ShopPage();
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

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/worlds')) return 1;
    if (location.startsWith('/profile')) return 2;
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

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 64,
        decoration: BoxDecoration(
          color: GamingColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: GamingColors.surfaceLight, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, index: 0, activeIndex: selectedIndex, icon: Icons.videogame_asset_outlined, activeIcon: Icons.videogame_asset, label: 'Lobby'),
            _buildNavItem(context, index: 1, activeIndex: selectedIndex, icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Map'),
            _buildNavItem(context, index: 2, activeIndex: selectedIndex, icon: Icons.person_outline, activeIcon: Icons.person, label: 'Hero'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int activeIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = index == activeIndex;
    final color = isActive ? GamingColors.primary : GamingColors.textMuted;

    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isActive ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
