import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GamingColors.background,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    children: [
                      Expanded(flex: 1, child: _buildEditorPane()),
                      Expanded(flex: 1, child: _buildGamePreviewPane()),
                    ],
                  );
                } else {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 500, child: _buildEditorPane()),
                        SizedBox(height: 500, child: _buildGamePreviewPane()),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: GamingColors.surface,
        border: Border(bottom: BorderSide(color: GamingColors.surfaceLight)),
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: GamingColors.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.code, color: GamingColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'CODEQUEST',
                style: TextStyle(
                  color: GamingColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          if (isDesktop) ...[
            const SizedBox(width: 48),
            // Nav Links
            _buildNavTab('EDITOR', true),
            _buildNavTab('DASHBOARD', false),
            _buildNavTab('QUESTS', false),
            _buildNavTab('COMMUNITY', false),
            _buildNavTab('SHOP', false),
          ],
          const Spacer(),
          // Profile
          profileState.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (profile) => Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: GamingColors.surfaceLight,
                  // Use a local icon fallback instead of network image if failing
                  child: const Icon(Icons.person, size: 16, color: GamingColors.textPrimary),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.username.toUpperCase(),
                        style: const TextStyle(color: GamingColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'LEVEL ${profile.level}, ${profile.xp} XP',
                        style: const TextStyle(color: GamingColors.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ],
                const SizedBox(width: 16),
                const Icon(Icons.settings_outlined, color: GamingColors.textMuted, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTab(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? GamingColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? GamingColors.textPrimary : GamingColors.textMuted,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEditorPane() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GamingColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GamingColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Editor Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GamingColors.surfaceLight)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SCRIPT: PLAYER_MOVEMENT.JS',
                  style: TextStyle(color: GamingColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: GamingColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Active', style: TextStyle(color: GamingColors.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // File Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GamingColors.surfaceLight)),
            ),
            child: Row(
              children: [
                _buildFileTab('PLAYER.JS', true),
                _buildFileTab('INPUT.JS', false),
                _buildFileTab('ENEMY.JS', false),
              ],
            ),
          ),
          // Code Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: GamingColors.background,
              child: SingleChildScrollView(
                child: Text(
                  '''
import { Player } from 'code-quest';
import { Input } from './input.js';

class PLAYER_MOVEMENT {
  constructor() {
    this.player = new Player();
    this.inputEnabled = true;
    this.enemyFlag = true;
    this.objects = true;
    this.associate = false;
  }
  
  function update() { // move to update
    // update initial
    var coins = new Coins();
    var cons = new Tensor();
    // count an item to run
    system.out.login("player_movement.script");
  }
}
                  ''',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: GamingColors.textSecondary,
                    height: 1.6,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: GamingColors.surfaceLight)),
            ),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Logic to launch game
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GamingColors.primary,
                    foregroundColor: GamingColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('RUN CODE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GamingColors.textPrimary,
                    side: const BorderSide(color: GamingColors.surfaceLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('DEBUG', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileTab(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isActive ? GamingColors.secondary : GamingColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: GamingColors.primary, shape: BoxShape.circle)),
              ]
            ],
          ),
          const SizedBox(height: 12),
          if (isActive)
            Container(height: 2, width: 60, color: GamingColors.secondary)
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildGamePreviewPane() {
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
      child: Column(
        children: [
          // 3D Game Preview Box
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: GamingColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GamingColors.surfaceLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '3D GAME PREVIEW',
                          style: TextStyle(color: GamingColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: GamingColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('REAL TIME', style: TextStyle(color: GamingColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  // Fake 3D Viewport
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF020617), // Deepest slate blue
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: GamingColors.surfaceLight),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'LEVEL: 1-4 | SCORE: 850 | HEALTH: 100',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Playback Controls
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow, color: GamingColors.textPrimary, size: 20),
                        const SizedBox(width: 16),
                        const Icon(Icons.pause, color: GamingColors.textMuted, size: 16),
                        const SizedBox(width: 16),
                        const Icon(Icons.stop, color: GamingColors.textMuted, size: 16),
                        const SizedBox(width: 16),
                        const Icon(Icons.refresh, color: GamingColors.textMuted, size: 16),
                        const SizedBox(width: 24),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: 0.7,
                            backgroundColor: GamingColors.surfaceLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(GamingColors.secondary),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Gamification Stats Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GamingColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GamingColors.surfaceLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'GAMIFICATION STATS',
                  style: TextStyle(color: GamingColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const Divider(color: GamingColors.surfaceLight, height: 32),
                _buildStatRow('Current Task:', 'Jump Mechanics (Completed: 6/10)', GamingColors.textPrimary),
                const SizedBox(height: 12),
                _buildStatRow('Achievement:', '"Neon Walker" Unlocked! 🏆', GamingColors.textPrimary),
                const SizedBox(height: 12),
                _buildStatRow('Points:', '+150 XP', GamingColors.primary),
                const SizedBox(height: 12),
                _buildStatRow('Streak:', '7 Days', GamingColors.textPrimary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: GamingColors.textMuted, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
