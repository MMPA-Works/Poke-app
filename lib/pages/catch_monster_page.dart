import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:torch_light/torch_light.dart';

import '../models/monster_model.dart';
import '../services/api_service.dart';
import '../config/user_session.dart';

class CatchMonsterPage extends StatefulWidget {
  const CatchMonsterPage({super.key});

  @override
  State<CatchMonsterPage> createState() => _CatchMonsterPageState();
}

class _CatchMonsterPageState extends State<CatchMonsterPage> {
  final MapController _mapController = MapController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<MonsterModel> _monsters = [];
  LatLng? _currentLocation;
  bool _isLoading = true;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadMonsters();
    await _updateCurrentLocation();
  }

  Future<void> _loadMonsters() async {
    try {
      final monsters = await ApiService.getMonsters();
      if (mounted) {
        setState(() {
          _monsters = monsters;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load monsters: $e')));
      }
    }
  }

  Future<void> _updateCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied.');
        }
      }

      // Using desiredAccuracy to maintain compatibility with your geolocator version
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // --- CORE EXAM REQUIREMENT: DISTANCE & HARDWARE TRIGGER ---
  Future<void> _detectMonsters() async {
    if (_currentLocation == null) {
      await _updateCurrentLocation();
      if (_currentLocation == null) return;
    }

    setState(() => _isDetecting = true);

    MonsterModel? nearestMonster;
    double minDistance = double.infinity;

    // 1. Geolocator distance calculation
    for (var monster in _monsters) {
      double distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        monster.spawnLatitude,
        monster.spawnLongitude,
      );

      if (distance <= monster.spawnRadiusMeters && distance < minDistance) {
        minDistance = distance;
        nearestMonster = monster;
      }
    }

    setState(() => _isDetecting = false);

    if (nearestMonster != null) {
      // 2. Trigger Hardware (Audio & Flashlight)
      _triggerHardwareAlert();

      // 3. Show Catch Dialog
      _showCatchDialog(nearestMonster, minDistance);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No monsters in range right now.')),
      );
    }
  }

  Future<void> _triggerHardwareAlert() async {
    // Play Alarm Sound
    try {
      await _audioPlayer.play(AssetSource('sounds/monster_alarm.wav'));
    } catch (e) {
      debugPrint('Audio error: $e');
    }

    // Flashlight Logic (5 seconds = 5 loops of 1 second)
    try {
      bool hasTorch = await TorchLight.isTorchAvailable();
      if (hasTorch) {
        for (int i = 0; i < 5; i++) {
          await TorchLight.enableTorch();
          await Future.delayed(const Duration(milliseconds: 500));
          await TorchLight.disableTorch();
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      debugPrint('Torch error: $e');
    }
  }

  void _showCatchDialog(MonsterModel monster, double distance) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Monster Detected near you!'),
        content: Text(
          '${monster.monsterName} (${monster.monsterType}) is only ${distance.toStringAsFixed(2)} meters away!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _audioPlayer.stop(); // Stop sound if they cancel early
              Navigator.pop(context);
            },
            child: const Text('Run Away'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _catchMonster(monster);
            },
            child: const Text('Catch!'),
          ),
        ],
      ),
    );
  }

  Future<void> _catchMonster(MonsterModel monster) async {
    if (UserSession.playerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You must be logged in to catch!')),
      );
      return;
    }

    // Stop audio just in case it is still playing
    _audioPlayer.stop();

    final result = await ApiService.catchMonster(
      UserSession.playerId!,
      monster.monsterId,
      _currentLocation!.latitude,
      _currentLocation!.longitude,
    );

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully caught ${monster.monsterName}!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to catch.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catch Monsters')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation ?? const LatLng(0, 0),
                      initialZoom: 16.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.haumonsters',
                      ),
                      // Monster Spawn Radiuses
                      CircleLayer(
                        circles: _monsters
                            .map(
                              (m) => CircleMarker(
                                point: LatLng(
                                  m.spawnLatitude,
                                  m.spawnLongitude,
                                ),
                                radius: m.spawnRadiusMeters,
                                useRadiusInMeter: true,
                                color: Colors.red.withOpacity(0.2),
                                borderColor: Colors.red,
                                borderStrokeWidth: 2,
                              ),
                            )
                            .toList(),
                      ),
                      // Markers
                      MarkerLayer(
                        markers: [
                          // Player Location Marker
                          if (_currentLocation != null)
                            Marker(
                              point: _currentLocation!,
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 40,
                              ),
                            ),
                          // Monster Markers
                          ..._monsters.map(
                            (m) => Marker(
                              point: LatLng(m.spawnLatitude, m.spawnLongitude),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.pets,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bottom Control Panel matching the exam wireframe
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      if (_currentLocation != null) ...[
                        Text(
                          'Your Latitude: ${_currentLocation!.latitude}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Your Longitude: ${_currentLocation!.longitude}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _isDetecting ? null : _detectMonsters,
                          icon: _isDetecting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.radar),
                          label: const Text('Detect Monsters'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
