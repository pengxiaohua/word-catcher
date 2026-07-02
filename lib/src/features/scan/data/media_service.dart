import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaService(ImagePicker());
});

class MediaService {
  const MediaService(this._picker);

  final ImagePicker _picker;

  Future<XFile?> pickImage(ImageSource source) {
    return _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1600,
      maxHeight: 1600,
    );
  }
}
