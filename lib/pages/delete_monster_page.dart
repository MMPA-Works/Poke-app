import 'package:flutter/material.dart';

import '../models/monster_model.dart';
import '../services/api_service.dart';

class DeleteMonsterPage extends StatefulWidget {
  const DeleteMonsterPage({super.key});

  @override
  State<DeleteMonsterPage> createState() => _DeleteMonsterPageState();
}

class _DeleteMonsterPageState extends State<DeleteMonsterPage> {
  final _apiService = ApiService();

  List<MonsterModel> _monsters = const [];
  bool _isLoading = true;
  int? _deletingMonsterId;
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

  Future<void> _confirmDelete(MonsterModel monster) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Monster'),
          content: Text('Delete ${monster.monsterName} permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteMonster(monster);
    }
  }

  Future<void> _deleteMonster(MonsterModel monster) async {
    setState(() {
      _deletingMonsterId = monster.monsterId;
    });

    try {
      await _apiService.deleteMonster(monster.monsterId);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Monster deleted successfully.')),
        );

      await _loadMonsters();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(_formatError(error)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _deletingMonsterId = null;
        });
      }
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
        title: const Text('Delete Monsters'),
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
            ? _DeletePageMessage(
                icon: Icons.error_outline,
                title: 'Unable to load monsters',
                subtitle: _errorMessage!,
                actionLabel: 'Retry',
                onPressed: _loadMonsters,
              )
            : _monsters.isEmpty
            ? _DeletePageMessage(
                icon: Icons.pets_outlined,
                title: 'Nothing to delete',
                subtitle:
                    'The backend returned no monsters. Add one first, then return here.',
                actionLabel: 'Refresh',
                onPressed: _loadMonsters,
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
                    final isDeleting = _deletingMonsterId == monster.monsterId;

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: _DeleteMonsterImage(
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
                            'ID: ${monster.monsterId}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: FilledButton.tonalIcon(
                          onPressed: isDeleting
                              ? null
                              : () => _confirmDelete(monster),
                          icon: isDeleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Icon(Icons.delete_outline),
                          label: Text(isDeleting ? 'Deleting...' : 'Delete'),
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

class _DeleteMonsterImage extends StatelessWidget {
  const _DeleteMonsterImage({this.pictureUrl});

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

class _DeletePageMessage extends StatelessWidget {
  const _DeletePageMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
