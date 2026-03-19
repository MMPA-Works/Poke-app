import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../services/api_service.dart';
import '../widgets/monster_image_preview.dart';

class AddMonsterPage extends StatefulWidget {
  const AddMonsterPage({super.key});

  @override
  State<AddMonsterPage> createState() => _AddMonsterPageState();
}

class _AddMonsterPageState extends State<AddMonsterPage> {
  static const LatLng _fallbackCenter = LatLng(14.5995, 120.9842);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _radiusController = TextEditingController(text: '100');
  final _mapController = MapController();
  final _imagePicker = ImagePicker();

  LatLng _mapCenter = _fallbackCenter;
  LatLng? _selectedPoint;
  File? _selectedImage;
  bool _isSaving = false;
  bool _isResolvingLocation = true;
  String _mapHint = 'Getting your current location...';

  bool get _isBusy => _isSaving || _isResolvingLocation;

  double get _radiusValue =>
      double.tryParse(_radiusController.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isResolvingLocation = true;
      _mapHint = 'Getting your current location...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const ApiException(
          'Location services are disabled. Turn on GPS and try again.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const ApiException(
          'Location permission is required to load your current position.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final point = LatLng(position.latitude, position.longitude);
      if (!mounted) {
        return;
      }

      setState(() {
        _mapCenter = point;
        _selectedPoint = point;
        _mapHint = 'Tap the map to set the monster spawn point.';
        _isResolvingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(point, 15);
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isResolvingLocation = false;
        _mapHint = 'Location unavailable. Tap the map to choose a spawn point.';
      });
      _showSnackBar(_formatError(error), isError: true);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isBusy) {
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

  Future<void> _saveMonster() async {
    if (_isBusy) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPoint == null) {
      _showSnackBar('Tap the map to choose a spawn point.', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? pictureUrl;
      if (_selectedImage != null) {
        pictureUrl = await ApiService.uploadMonsterImage(_selectedImage!);
      }

      await ApiService.addMonster(
        monsterName: _nameController.text.trim(),
        monsterType: _typeController.text.trim(),
        spawnLatitude: _selectedPoint!.latitude,
        spawnLongitude: _selectedPoint!.longitude,
        spawnRadiusMeters: _radiusValue,
        pictureUrl: pictureUrl,
      );

      if (!mounted) {
        return;
      }

      _showSnackBar('Monster added successfully.', isError: false);
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
      _mapCenter = point;
      _mapHint = 'Spawn point updated. Adjust it again by tapping the map.';
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
    final markerPoint = _selectedPoint;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Monster')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Monster Name',
                icon: Icons.pets_outlined,
                validatorMessage: 'Enter the monster name.',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _typeController,
                label: 'Monster Type',
                icon: Icons.category_outlined,
                validatorMessage: 'Enter the monster type.',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _radiusController,
                label: 'Spawn Radius (meters)',
                icon: Icons.radar_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validatorMessage: 'Enter a valid spawn radius.',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Text(
                'Spawn Point',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(_mapHint),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 320,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _mapCenter,
                      initialZoom: 15,
                      onTap: _handleMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.haumonsters',
                      ),
                      if (markerPoint != null)
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: markerPoint,
                              radius: circleRadius,
                              useRadiusInMeter: true,
                              borderStrokeWidth: 2,
                              borderColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(48),
                            ),
                          ],
                        ),
                      if (markerPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: markerPoint,
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
              if (markerPoint != null)
                Text(
                  'Selected: ${markerPoint.latitude.toStringAsFixed(5)}, '
                  '${markerPoint.longitude.toStringAsFixed(5)}',
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
                      onPressed: _isBusy
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isBusy
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              MonsterImagePreview(selectedImage: _selectedImage),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isBusy ? null : _saveMonster,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isSaving ? 'Saving...' : 'Save Monster'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMessage,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onChanged: onChanged,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return validatorMessage;
        }
        if (keyboardType != null && double.tryParse(text) == null) {
          return validatorMessage;
        }
        if (keyboardType != null && double.parse(text) <= 0) {
          return 'Spawn radius must be greater than zero.';
        }
        return null;
      },
    );
  }
}