import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../models/monster_model.dart';
import '../services/api_service.dart';
import '../widgets/monster_image_preview.dart';

class EditMonsterPage extends StatefulWidget {
  const EditMonsterPage({super.key, required this.monster});

  final MonsterModel monster;

  @override
  State<EditMonsterPage> createState() => _EditMonsterPageState();
}

class _EditMonsterPageState extends State<EditMonsterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _radiusController = TextEditingController();
  final _mapController = MapController();
  final _apiService = ApiService();
  final _imagePicker = ImagePicker();

  late final LatLng _initialPoint;
  late LatLng _selectedPoint;
  File? _selectedImage;
  bool _isSaving = false;

  double get _radiusValue =>
      double.tryParse(_radiusController.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.monster.monsterName;
    _typeController.text = widget.monster.monsterType;
    _radiusController.text = widget.monster.spawnRadiusMeters.toStringAsFixed(
      0,
    );
    _initialPoint = LatLng(
      widget.monster.spawnLatitude,
      widget.monster.spawnLongitude,
    );
    _selectedPoint = _initialPoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isSaving) {
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1440,
      );

      if (pickedFile == null || !mounted) {
        return;
      }

      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(_formatError(error), isError: true);
    }
  }

  Future<void> _updateMonster() async {
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? pictureUrl = widget.monster.pictureUrl;
      if (_selectedImage != null) {
        pictureUrl = await _apiService.uploadMonsterImage(_selectedImage!);
      }

      final updatedMonster = widget.monster.copyWith(
        monsterName: _nameController.text.trim(),
        monsterType: _typeController.text.trim(),
        spawnLatitude: _selectedPoint.latitude,
        spawnLongitude: _selectedPoint.longitude,
        spawnRadiusMeters: _radiusValue,
        pictureUrl: pictureUrl,
      );

      await _apiService.updateMonster(updatedMonster);

      if (!mounted) {
        return;
      }

      _showSnackBar('Monster updated successfully.', isError: false);
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(_formatError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (_isSaving) {
      return;
    }

    setState(() {
      _selectedPoint = point;
    });
  }

  void _showSnackBar(String message, {required bool isError}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  String _formatError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final circleRadius = _radiusValue <= 0 ? 1.0 : _radiusValue;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Monster')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Monster Name',
                  prefixIcon: const Icon(Icons.pets_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Enter the monster name.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Monster Type',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Enter the monster type.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _radiusController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Spawn Radius (meters)',
                  prefixIcon: const Icon(Icons.radar_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  final parsed = double.tryParse(text);
                  if (parsed == null) {
                    return 'Enter a valid spawn radius.';
                  }
                  if (parsed <= 0) {
                    return 'Spawn radius must be greater than zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Spawn Point',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text('Tap the map to move the spawn point.'),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 320,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _initialPoint,
                      initialZoom: 15,
                      onTap: _handleMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.haumonsters',
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: _selectedPoint,
                            radius: circleRadius,
                            useRadiusInMeter: true,
                            borderStrokeWidth: 2,
                            borderColor: Theme.of(context).colorScheme.primary,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(48),
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint,
                            width: 52,
                            height: 52,
                            child: Icon(
                              Icons.location_on,
                              size: 44,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selected: ${_selectedPoint.latitude.toStringAsFixed(5)}, '
                '${_selectedPoint.longitude.toStringAsFixed(5)}',
              ),
              const SizedBox(height: 20),
              Text(
                'Monster Image',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MonsterImagePreview(
                selectedImage: _selectedImage,
                pictureUrl: widget.monster.pictureUrl,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _updateMonster,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Updating...' : 'Update Monster'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
