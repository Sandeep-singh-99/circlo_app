import 'dart:io';

import 'package:flutter/material.dart';

/// Shows the selected image with a remove (✕) and a "Change" overlay button.
class ImagePickerPreview extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;
  final VoidCallback onChange;
  final double height;

  const ImagePickerPreview({
    super.key,
    required this.image,
    required this.onRemove,
    required this.onChange,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            image,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
          ),
        ),

        // Remove button (top-right)
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),

        // Change button (bottom-right)
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: onChange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty placeholder that prompts the user to add a photo.
class AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  final double height;

  const AddImageButton({super.key, required this.onTap, this.height = 220});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: cs.onSurface.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.onSurface.withAlpha(40), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: cs.onSurface.withAlpha(100),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to add a photo',
              style: TextStyle(
                fontSize: 15,
                color: cs.onSurface.withAlpha(130),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'From gallery or camera',
              style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(80)),
            ),
          ],
        ),
      ),
    );
  }
}
