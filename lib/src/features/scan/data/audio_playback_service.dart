import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioPlaybackServiceProvider = Provider<AudioPlaybackService>((ref) {
  final service = AudioPlaybackService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

class AudioPlaybackService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playUrl(String url) async {
    if (url.isEmpty) {
      throw ArgumentError('Audio url is empty.');
    }
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  Future<void> dispose() => _player.dispose();
}
