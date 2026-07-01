import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/gaming_colors.dart';
import '../../../../core/widgets/game_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/badge_widget.dart';
import '../../../../core/services/firebase_service.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: profileState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: GamingColors.primary),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error loading profile: $err'),
            ),
          ),
          data: (profile) {
            return ResponsiveLayout(
              mobile: _buildMobileLayout(context, profile),
              desktop: _buildDesktopLayout(context, profile),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, dynamic profile) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: _buildAvatarCard(context, profile),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarActiveTabsDelegate(
              tabBar: TabBar(
                controller: _tabController,
                indicatorColor: GamingColors.primary,
                labelColor: GamingColors.primary,
                unselectedLabelColor: GamingColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                tabs: const [
                  Tab(text: 'ATTRIBUTES', icon: Icon(Icons.bolt, size: 18)),
                  Tab(text: 'BADGE VAULT', icon: Icon(Icons.stars, size: 18)),
                  Tab(text: 'SCROLLS', icon: Icon(Icons.history_edu, size: 18)),
                  Tab(text: 'CLAN CORES', icon: Icon(Icons.people, size: 18)),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAttributesTab(context, profile),
          _buildBadgeVaultTab(context, profile),
          _buildReflectionScrollsTab(context, profile),
          _buildClanCoresTab(context),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, dynamic profile) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildAvatarCard(context, profile),
                  const SizedBox(height: 24),
                  _buildActionPanel(context),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: GamingColors.primary,
                  labelColor: GamingColors.primary,
                  unselectedLabelColor: GamingColors.textMuted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  tabs: const [
                    Tab(text: 'ATTRIBUTES', icon: Icon(Icons.bolt, size: 20)),
                    Tab(text: 'BADGE VAULT', icon: Icon(Icons.stars, size: 20)),
                    Tab(text: 'REFLECTION SCROLLS', icon: Icon(Icons.history_edu, size: 20)),
                    Tab(text: 'CLAN CORES', icon: Icon(Icons.people, size: 20)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAttributesTab(context, profile),
                      _buildBadgeVaultTab(context, profile),
                      _buildReflectionScrollsTab(context, profile),
                      _buildClanCoresTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(BuildContext context, dynamic profile) {
    final theme = Theme.of(context);
    final xpPercent = (profile.xp % 500) / 500.0; // Assume 500 XP per level

    return GameCard(
      borderColor: GamingColors.primary,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.logout, color: GamingColors.error, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logging out warrior...')),
                );
              },
            ),
          ),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: GamingColors.primary, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: GamingColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: GamingColors.surfaceLight,
                    backgroundImage: NetworkImage(profile.avatarUrl),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile.username.toUpperCase(),
                  style: theme.textTheme.displayMedium?.copyWith(
                    letterSpacing: 1.0,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(color: GamingColors.textMuted, fontSize: 11),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: GamingColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GamingColors.secondary),
                      ),
                      child: Text(
                        'LEVEL ${profile.level}',
                        style: const TextStyle(
                          color: GamingColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: GamingColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GamingColors.accent),
                      ),
                      child: Text(
                        profile.rank.toUpperCase(),
                        style: const TextStyle(
                          color: GamingColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('XP Progress: ${profile.xp % 500} / 500', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                        Text('${(xpPercent * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: GamingColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: xpPercent,
                        backgroundColor: GamingColors.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(GamingColors.primary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesTab(BuildContext context, dynamic profile) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'CHARACTER STATS & ATTRIBUTES',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.25,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildAttributeGauge('CODE SPEED', '85/100', 0.85, Icons.flash_on, GamingColors.primary),
            _buildAttributeGauge('DATA LOGIC', '72/100', 0.72, Icons.folder_zip, GamingColors.secondary),
            _buildAttributeGauge('RECURSION DEPTH', '64/100', 0.64, Icons.cached, GamingColors.warning),
            _buildAttributeGauge('MEMORY BUFFERS', '90/100', 0.90, Icons.memory, GamingColors.accent),
          ],
        ),
        const SizedBox(height: 24),
        _buildActionPanel(context),
      ],
    );
  }

  Widget _buildAttributeGauge(String name, String valStr, double percent, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GamingColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: GamingColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(valStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeVaultTab(BuildContext context, dynamic profile) {
    final List<Map<String, dynamic>> mockBadges = [
      {
        'id': 'HelloWorld',
        'title': 'Hello World',
        'desc': 'Write your first line of code.',
        'icon': Icons.chat_bubble_outline,
        'tier': BadgeTier.bronze,
      },
      {
        'id': 'RecursionRider',
        'title': 'Recursion Rider',
        'desc': 'Complete recursive quest.',
        'icon': Icons.repeat,
        'tier': BadgeTier.gold,
      },
      {
        'id': 'ArrayAce',
        'title': 'Array Ace',
        'desc': 'Master matrix operations.',
        'icon': Icons.grid_on,
        'tier': BadgeTier.diamond,
      },
      {
        'id': 'LoopLegend',
        'title': 'Loop Legend',
        'desc': 'Traverse complex loops.',
        'icon': Icons.sync,
        'tier': BadgeTier.legend,
      }
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'BADGES & ACCOMPLISHMENTS',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: mockBadges.length,
          itemBuilder: (context, index) {
            final badge = mockBadges[index];
            final hasUnlocked = profile.achievements.contains(badge['id']);
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GamingColors.surfaceLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasUnlocked ? GamingColors.accent.withValues(alpha: 0.4) : Colors.white10,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BadgeWidget(
                    tier: badge['tier'] as BadgeTier,
                    icon: badge['icon'] as IconData,
                    title: badge['title'] as String,
                    description: badge['desc'] as String,
                    isUnlocked: hasUnlocked,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    badge['title'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: hasUnlocked ? Colors.white : Colors.white30,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    badge['desc'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 8,
                      color: hasUnlocked ? Colors.white54 : Colors.white24,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReflectionScrollsTab(BuildContext context, dynamic profile) {
    // Dynamic analytics reflections from FirebaseService + pre-populated logs
    final submittedReflections = FirebaseService.instance.mockAnalyticsLogs;

    final List<Map<String, dynamic>> staticScrolls = [
      {
        'gameId': 'level_1',
        'title': 'The Lost Stones (Stack Temple)',
        'confidence': 5,
        'reflection': 'I realized that the last stone added is the first one needed to balance the stack structure. This matches the LIFO ordering concept perfectly.',
        'date': 'Yesterday',
      },
      {
        'gameId': 'level_2',
        'title': 'Temple Memory (Queue Station)',
        'confidence': 4,
        'reflection': 'Ordering the runic energy segments in sequence taught me that FIFO processing ensures fair routing without deadlocks.',
        'date': '2 days ago',
      },
    ];

    // Map dynamic reflections to matching structure
    final dynamicScrolls = submittedReflections.map((r) => {
      'gameId': r['gameId'] ?? 'unknown',
      'title': (r['gameId'] == 'level_1')
          ? 'The Lost Stones'
          : (r['gameId'] == 'level_2')
              ? 'Temple Memory'
              : (r['gameId'] == 'level_3')
                  ? 'Trap Escape'
                  : 'Guardian Escape (Boss)',
      'confidence': r['confidenceScore'] ?? 4,
      'reflection': r['reflectionResponse'] ?? '',
      'date': 'Just now',
    }).toList();

    final allScrolls = [...dynamicScrolls, ...staticScrolls];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: allScrolls.length,
      itemBuilder: (context, index) {
        final scroll = allScrolls[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: const Color(0xFF2C2514), // Gold-tinted dark background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5), // Gold outline
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      scroll['title'].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFD4AF37), fontSize: 12),
                    ),
                    Text(
                      scroll['date'],
                      style: const TextStyle(color: Colors.white30, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (starIdx) {
                    return Icon(
                      starIdx < (scroll['confidence'] as int) ? Icons.star : Icons.star_border,
                      color: const Color(0xFFD4AF37),
                      size: 14,
                    );
                  }),
                ),
                const SizedBox(height: 12),
                const Text(
                  'LOGGED REFLECTION:',
                  style: TextStyle(fontSize: 8, color: Colors.white30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${scroll['reflection']}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFF5DEB3), // Wheat text color
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClanCoresTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'ARENA DIVISIONS & CLAN CORE',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        GameCard(
          borderColor: GamingColors.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_outlined, color: GamingColors.secondary),
                  SizedBox(width: 8),
                  Text('WEEKLY DIVISION: GOLD I', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Top 3 progress into Diamond division at weekly reset.',
                style: TextStyle(fontSize: 11, color: GamingColors.textMuted),
              ),
              const Divider(color: Colors.white12, height: 24),
              _buildLeaderboardRow(1, 'AlgoAce', '980 XP', false),
              _buildLeaderboardRow(2, 'LIFO_Master', '945 XP', false),
              _buildLeaderboardRow(3, 'CodeWarrior (YOU)', '890 XP', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(int rank, String name, String score, bool isSelf) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('#$rank $name', style: TextStyle(fontSize: 11, fontWeight: isSelf ? FontWeight.bold : FontWeight.normal, color: isSelf ? GamingColors.secondary : Colors.white)),
          Text(score, style: TextStyle(fontSize: 11, fontWeight: isSelf ? FontWeight.bold : FontWeight.normal, color: isSelf ? GamingColors.secondary : Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildActionPanel(BuildContext context) {
    return GameCard(
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.security, color: GamingColors.primary),
            title: const Text('Runic Security & MFA'),
            trailing: const Icon(Icons.chevron_right, color: GamingColors.textMuted),
            onTap: () {},
          ),
          const Divider(color: GamingColors.surfaceLight, height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.headset_mic, color: GamingColors.primary),
            title: const Text('Support Portals'),
            trailing: const Icon(Icons.chevron_right, color: GamingColors.textMuted),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarActiveTabsDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarActiveTabsDelegate({required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0F172A),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarActiveTabsDelegate oldDelegate) {
    return false;
  }
}
