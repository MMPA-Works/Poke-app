import 'package:flutter/material.dart';

import '../models/monster_model.dart';
import '../services/api_service.dart';
import 'edit_monster_page.dart';

class EditMonstersPage extends StatefulWidget {
  const EditMonstersPage({super.key});

  @override
  State<EditMonstersPage> createState() => _EditMonstersPageState();
}

class _EditMonstersPageState extends State<EditMonstersPage> {
  final _apiService = ApiService();

  List<MonsterModel> _monsters = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMonsters();
  }

  Future<void> _loadMonsters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final monsters = await _apiService.getMonsters();
      if (!mounted) {
        return;
      }

      setState(() {
        _monsters = monsters;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = _formatError(error);
      });
    }
  }

  Future<void> _openEditMonster(MonsterModel monster) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditMonsterPage(monster: monster)),
    );

    if (updated == true && mounted) {
      await _loadMonsters();
    }
  }

  String _formatError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Monsters'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadMonsters,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _ErrorState(message: _errorMessage!, onRetry: _loadMonsters)
            : _monsters.isEmpty
            ? _EmptyState(
                title: 'No monsters found',
                subtitle: 'Add a monster first, then return here to edit it.',
                onRefresh: _loadMonsters,
              )
            : RefreshIndicator(
                onRefresh: _loadMonsters,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _monsters.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final monster = _monsters[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: _MonsterListImage(
                          pictureUrl: monster.pictureUrl,
                        ),
                        title: Text(
                          monster.monsterName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${monster.monsterType}\n'
                            'Lat: ${monster.spawnLatitude.toStringAsFixed(5)}\n'
                            'Lng: ${monster.spawnLongitude.toStringAsFixed(5)}\n'
                            'Radius: ${monster.spawnRadiusMeters.toStringAsFixed(1)} m',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: FilledButton(
                          onPressed: () => _openEditMonster(monster),
                          child: const Text('Edit'),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _MonsterListImage extends StatelessWidget {
  const _MonsterListImage({this.pictureUrl});

  final String? pictureUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiService.resolveImageUrl(pictureUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        height: 72,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: resolvedUrl == null
            ? const Icon(Icons.image_not_supported_outlined)
            : Image.network(
                resolvedUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image_outlined),
              ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  final String title;
  final String subtitle;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets_outlined, size: 44),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRefresh, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}
