import 'dart:io';

import 'package:flutter/material.dart';

import '../services/api_service.dart';

class MonsterImagePreview extends StatelessWidget {
  const MonsterImagePreview({
    super.key,
    this.selectedImage,
    this.pictureUrl,
    this.height = 220,
  });

  final File? selectedImage;
  final String? pictureUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiService.resolveImageUrl(pictureUrl);
    final borderRadius = BorderRadius.circular(18);

    Widget child;
    if (selectedImage != null) {
      child = ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          selectedImage!,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    } else if (resolvedUrl != null) {
      child = ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          resolvedUrl,
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _EmptyImageState(),
        ),
      );
    } else {
      child = const _EmptyImageState();
    }

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _EmptyImageState extends StatelessWidget {
  const _EmptyImageState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_not_supported_outlined, size: 40),
            SizedBox(height: 8),
            Text('No image selected'),
          ],
        ),
      ),
    );
  }
}
