import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';

class ShareCardPhoto extends StatelessWidget {
  const ShareCardPhoto({
    required this.imageUrl,
    this.localImagePath,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String imageUrl;
  final String? localImagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && localImagePath != null && localImagePath!.isNotEmpty) {
      return Image.file(
        File(localImagePath!),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const _PhotoFallback(),
      );
    }

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const _PhotoFallback(),
      );
    }

    return const _PhotoFallback();
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.photoFallback,
      child: Center(
        child: Icon(
          Icons.photo_camera_outlined,
          color: Colors.white70,
          size: 54,
        ),
      ),
    );
  }
}
