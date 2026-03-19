import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/monster_model.dart';
import '../services/api_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _fallbackCenter = LatLng(14.5995, 120.9842);

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
      // Changed to use the static method
      final monsters = await ApiService.getMonsters();
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

  void _showMonsterDetails(MonsterModel monster) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final imageUrl = ApiService.resolveImageUrl(monster.pictureUrl);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monster.monsterName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Type: ${monster.monsterType}'),
                Text(
                  'Location: ${monster.spawnLatitude.toStringAsFixed(5)}, '
                  '${monster.spawnLongitude.toStringAsFixed(5)}',
                ),
                Text(
                  'Radius: ${monster.spawnRadiusMeters.toStringAsFixed(1)} m',
                ),
                if (imageUrl != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  LatLng get _initialCenter {
    if (_monsters.isEmpty) {
      return _fallbackCenter;
    }

    final latitudeSum = _monsters
        .map((monster) => monster.spawnLatitude)
        .reduce((value, element) => value + element);
    final longitudeSum = _monsters
        .map((monster) => monster.spawnLongitude)
        .reduce((value, element) => value + element);

    return LatLng(
      latitudeSum / _monsters.length,
      longitudeSum / _monsters.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _monsters
        .map(
          (monster) => Marker(
            point: LatLng(monster.spawnLatitude, monster.spawnLongitude),
            width: 70,
            height: 70,
            child: GestureDetector(
              onTap: () => _showMonsterDetails(monster),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).colorScheme.error,
                    size: 42,
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        monster.monsterName,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();

    final circles = _monsters
        .map(
          (monster) => CircleMarker(
            point: LatLng(monster.spawnLatitude, monster.spawnLongitude),
            radius: monster.spawnRadiusMeters <= 0
                ? 1
                : monster.spawnRadiusMeters,
            useRadiusInMeter: true,
            borderStrokeWidth: 2,
            borderColor: Theme.of(context).colorScheme.primary,
            color: Theme.of(context).colorScheme.primary.withAlpha(44),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monster Map'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadMonsters,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _initialCenter,
                initialZoom: _monsters.isEmpty ? 12 : 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.haumonsters',
                ),
                CircleLayer(circles: circles),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Loading monsters...'),
                          ],
                        )
                      : _errorMessage != null
                      ? Row(
                          children: [
                            const Icon(Icons.error_outline),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_errorMessage!)),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(Icons.info_outline),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _monsters.isEmpty
                                    ? 'No monsters to display yet.'
                                    : '${_monsters.length} monster(s) loaded. Tap a marker for details.',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}