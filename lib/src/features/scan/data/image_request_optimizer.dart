import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

final imageRequestOptimizerProvider = Provider<ImageRequestOptimizer>((ref) {
  return const ImageRequestOptimizer();
});

class ImageRequestOptimizer {
  const ImageRequestOptimizer({
    this.targetMaxBytes = 900 * 1024,
    this.maxEdge = 1280,
  });

  final int targetMaxBytes;
  final int maxEdge;

  static const _minEdge = 840;
  static const _edgeStep = 160;
  static const _qualitySteps = [82, 76, 70, 64, 58];

  Future<OptimizedImagePayload> optimize(XFile image) async {
    final originalBytes = await image.readAsBytes();
    final decoded = img.decodeImage(originalBytes);

    if (decoded == null) {
      final mimeType = _guessMimeType(image.name, image.path);
      return OptimizedImagePayload(
        bytes: originalBytes,
        mimeType: mimeType,
        width: 0,
        height: 0,
      );
    }

    final oriented = img.bakeOrientation(decoded);
    final originalMimeType = _guessMimeType(image.name, image.path);
    if (_canUseOriginal(originalBytes, oriented, originalMimeType)) {
      return OptimizedImagePayload(
        bytes: originalBytes,
        mimeType: originalMimeType,
        width: oriented.width,
        height: oriented.height,
      );
    }

    OptimizedImagePayload? smallestPayload;
    for (var edge = maxEdge; edge >= _minEdge; edge = edge - _edgeStep) {
      final resized = _resizeToEdge(oriented, edge);
      for (final quality in _qualitySteps) {
        final encoded = Uint8List.fromList(
          img.encodeJpg(resized, quality: quality),
        );
        final payload = OptimizedImagePayload(
          bytes: encoded,
          mimeType: 'image/jpeg',
          width: resized.width,
          height: resized.height,
        );
        smallestPayload = payload;
        if (encoded.lengthInBytes <= targetMaxBytes) {
          return payload;
        }
      }
    }

    return smallestPayload ??
        OptimizedImagePayload(
          bytes: originalBytes,
          mimeType: originalMimeType,
          width: oriented.width,
          height: oriented.height,
        );
  }

  bool _canUseOriginal(Uint8List bytes, img.Image image, String mimeType) {
    final maxDimension = image.width > image.height
        ? image.width
        : image.height;
    return mimeType == 'image/jpeg' &&
        bytes.lengthInBytes <= targetMaxBytes &&
        maxDimension <= maxEdge;
  }

  img.Image _resizeToEdge(img.Image source, int edge) {
    if (source.width <= edge && source.height <= edge) {
      return source;
    }

    if (source.width >= source.height) {
      return img.copyResize(
        source,
        width: edge,
        interpolation: img.Interpolation.average,
      );
    }

    return img.copyResize(
      source,
      height: edge,
      interpolation: img.Interpolation.average,
    );
  }

  String _guessMimeType(String name, String path) {
    final source = name.isNotEmpty ? name : path;
    final lower = source.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}

class OptimizedImagePayload {
  const OptimizedImagePayload({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final String mimeType;
  final int width;
  final int height;

  int get byteSize => bytes.lengthInBytes;

  String get dataUrl => 'data:$mimeType;base64,${base64Encode(bytes)}';
}
