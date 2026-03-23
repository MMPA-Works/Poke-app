import 'package:flutter/material.dart';

import '../config/user_session.dart';
import 'add_monster_page.dart';
import 'catch_monster_page.dart';
import 'delete_monster_page.dart';
import 'display_ranking_page.dart';
import 'edit_monsters_page.dart';
import 'map_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <_DashboardAction>[
      _DashboardAction(
        title: 'Add Monsters',
        description: 'Create a monster with map location, radius, and image.',
        icon: Icons.add_box_outlined,
        color: const Color(0xFF1FAF53),
        surfaceColor: const Color(0xFFE7F8EC),
        destinationBuilder: (_) => const AddMonsterPage(),
      ),
      _DashboardAction(
        title: 'Edit Monsters',
        description: 'Load existing monsters and update their details.',
        icon: Icons.auto_fix_high_outlined,
        color: const Color(0xFF3A86F2),
        surfaceColor: const Color(0xFFEAF2FF),
        destinationBuilder: (_) => const EditMonstersPage(),
      ),
      _DashboardAction(
        title: 'Delete Monsters',
        description: 'Remove unwanted monsters from the backend list.',
        icon: Icons.delete_outline_rounded,
        color: const Color(0xFFE54848),
        surfaceColor: const Color(0xFFFFECEC),
        destinationBuilder: (_) => const DeleteMonsterPage(),
      ),
      _DashboardAction(
        title: 'Show Monster Map',
        description: 'Display every saved monster marker and spawn radius.',
        icon: Icons.explore_outlined,
        color: const Color(0xFF9B36F3),
        surfaceColor: const Color(0xFFF4EAFF),
        destinationBuilder: (_) => const MapPage(),
      ),
      _DashboardAction(
        title: 'Catch Monsters',
        description: 'Find and catch monsters near your physical location.',
        icon: Icons.track_changes,
        color: const Color(0xFFDE7B1F),
        surfaceColor: const Color(0xFFFFF2E5),
        destinationBuilder: (_) => const CatchMonsterPage(),
      ),
      _DashboardAction(
        title: 'Top Monster Hunters',
        description: 'See the leaderboard of players with the most catches.',
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFC89B17),
        surfaceColor: const Color(0xFFFFF7DE),
        destinationBuilder: (_) => const DisplayRankingPage(),
      ),
    ];

    final playerName = UserSession.playerName?.trim();
    final greetingName = playerName == null || playerName.isEmpty
        ? 'Hunter'
        : playerName;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7EF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Command Center',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1D231D),
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 18),
              _DashboardStatusCard(greetingName: greetingName),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 760 ? 3 : 2;
                  final childAspectRatio = constraints.maxWidth >= 760
                      ? 0.97
                      : constraints.maxWidth < 390
                      ? 0.72
                      : 0.80;

                  return GridView.builder(
                    itemCount: actions.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      return _DashboardCard(action: actions[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardStatusCard extends StatelessWidget {
  const _DashboardStatusCard({required this.greetingName});

  final String greetingName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF20835F), Color(0xFF124E3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF124E3D).withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF61E58A),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SYSTEM ACTIVE',
                style: textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFB6F1C5),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'HAUMonsters Finals',
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Operational dashboard for monster control and field actions. Welcome, $greetingName.',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.80),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: action.destinationBuilder));
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: action.surfaceColor,
            border: Border.all(
              color: action.color.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: action.color,
                    boxShadow: [
                      BoxShadow(
                        color: action.color.withValues(alpha: 0.24),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(action.icon, color: Colors.white, size: 27),
                ),
                const SizedBox(height: 14),
                Text(
                  action.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F241E),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B746A),
                    height: 1.32,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: action.color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.surfaceColor,
    required this.destinationBuilder,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color surfaceColor;
  final WidgetBuilder destinationBuilder;
}
