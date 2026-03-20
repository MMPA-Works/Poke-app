import 'package:flutter/material.dart';

import '../models/player_ranking_model.dart';
import '../services/api_service.dart';

class DisplayRankingPage extends StatefulWidget {
  const DisplayRankingPage({super.key});

  @override
  State<DisplayRankingPage> createState() => _DisplayRankingPageState();
}

class _DisplayRankingPageState extends State<DisplayRankingPage> {
  // Storing the Future in a variable is a best practice to prevent
  // unnecessary API calls every time the widget rebuilds.
  late Future<List<PlayerRanking>> _rankingsFuture;

  @override
  void initState() {
    super.initState();
    _rankingsFuture = ApiService.getPlayerRankings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Monster Hunters')),
      body: FutureBuilder<List<PlayerRanking>>(
        future: _rankingsFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Error State
          else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading rankings. Please try again.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          // 3. Empty State
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No monsters have been caught yet! Go catch some!'),
            );
          }

          // 4. Success State
          final rankings = snapshot.data!;

          return ListView.builder(
            itemCount: rankings.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final player = rankings[index];

              // Custom colors for Top 3
              Color rankColor;
              if (index == 0) {
                rankColor = Colors.amber; // Gold
              } else if (index == 1) {
                rankColor = Colors.grey.shade400; // Silver
              } else if (index == 2) {
                rankColor = Colors.orange.shade300; // Bronze
              } else {
                rankColor = Colors.blueGrey.shade100;
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rankColor,
                    child: Text(
                      '#${index + 1}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    player.playerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${player.monstersCaught}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.0, // Removes invisible vertical padding
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Text(
                          'Caught',
                          style: TextStyle(
                            fontSize: 12, 
                            height: 1.0, // Removes invisible vertical padding
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
