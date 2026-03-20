import 'package:flutter/material.dart';

import 'add_monster_page.dart';
import 'delete_monster_page.dart';
import 'edit_monsters_page.dart';
import 'map_page.dart';
import 'catch_monster_page.dart';
import 'display_ranking_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <_DashboardAction>[
      _DashboardAction(
        title: 'Add Monsters',
        description: 'Create a monster with map location, radius, and image.',
        icon: Icons.add_circle_outline,
        color: const Color(0xFF2E7D32),
        destinationBuilder: (_) => const AddMonsterPage(),
      ),
      _DashboardAction(
        title: 'Edit Monsters',
        description: 'Load existing monsters and update their details.',
        icon: Icons.edit_outlined,
        color: const Color(0xFF1565C0),
        destinationBuilder: (_) => const EditMonstersPage(),
      ),
      _DashboardAction(
        title: 'Delete Monsters',
        description: 'Remove unwanted monsters from the backend list.',
        icon: Icons.delete_outline,
        color: const Color(0xFFC62828),
        destinationBuilder: (_) => const DeleteMonsterPage(),
      ),
      _DashboardAction(
        title: 'Show Monster Map',
        description: 'Display every saved monster marker and spawn radius.',
        icon: Icons.map_outlined,
        color: const Color(0xFF6A1B9A),
        destinationBuilder: (_) => const MapPage(),
      ),
      // NEW: Catch Monsters Action
      _DashboardAction(
        title: 'Catch Monsters',
        description: 'Find and catch monsters near your physical location.',
        icon: Icons.track_changes,
        color: const Color(0xFFE65100),
        destinationBuilder: (_) => const CatchMonsterPage(),
      ),
      // NEW: Leaderboard Action
      _DashboardAction(
        title: 'View Top Monster Hunters',
        description: 'See the leaderboard of players with the most catches.',
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFF57F17),
        destinationBuilder: (_) => const DisplayRankingPage(),
      ),
    ];

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Monster Control Center')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 620 ? 2 : 1;
            final childAspectRatio = crossAxisCount == 2 ? 1.35 : 1.5;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1F7A5A), Color(0xFF114E3D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HAUMonsters Finals App',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage monsters, catch them in the wild, and check the leaderboards.',
                          style: textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      itemCount: actions.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final action = actions[index];
                        return _DashboardCard(action: action);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.action});

  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: action.destinationBuilder));
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: action.color.withAlpha(28),
                child: Icon(action.icon, color: action.color, size: 28),
              ),
              const Spacer(),
              Text(
                action.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                action.description,
                style: Theme.of(context).textTheme.bodyMedium,
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

class _DashboardAction {
  const _DashboardAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.destinationBuilder,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final WidgetBuilder destinationBuilder;
}