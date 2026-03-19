import 'package:flutter/material.dart';

import '../models/monster_model.dart';
import '../services/api_service.dart';

class DeleteMonsterPage extends StatefulWidget {
  const DeleteMonsterPage({super.key});

  @override
  State<DeleteMonsterPage> createState() => _DeleteMonsterPageState();
}

class _DeleteMonsterPageState extends State<DeleteMonsterPage> {
  late Future<List<MonsterModel>> _monstersFuture;

  @override
  void initState() {
    super.initState();
    _loadMonsters();
  }

  void _loadMonsters() {
    _monstersFuture = ApiService.getMonsters();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadMonsters();
    });
  }

  Future<void> _deleteMonster(MonsterModel monster) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Monster'),
          content: Text('Are you sure you want to delete ${monster.monsterName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final result = await ApiService.deleteMonster(
        monsterId: monster.monsterId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]?.toString() ?? "Done"),
        ),
      );
      
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Monsters"),
      ),
      body: FutureBuilder<List<MonsterModel>>(
        future: _monstersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final monsters = snapshot.data ?? [];

          if (monsters.isEmpty) {
            return const Center(child: Text("No monsters found"));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: monsters.length,
              itemBuilder: (context, index) {
                final monster = monsters[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: monster.pictureUrl != null &&
                            monster.pictureUrl!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(monster.pictureUrl!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.image_not_supported),
                          ),
                    title: Text(monster.monsterName),
                    subtitle: Text(monster.monsterType),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMonster(monster),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}