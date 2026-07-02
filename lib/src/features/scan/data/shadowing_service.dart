import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

final shadowingServiceProvider = Provider<ShadowingService>((ref) {
  final service = ShadowingService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

class ShadowingService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw StateError('Microphone permission was not granted.');
    }

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/shadowing_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
  }

  Future<String?> stopRecording() {
    return _recorder.stop();
  }

  Future<ShadowingEvaluation> evaluateShadowing({
    required String audioPath,
    required String referenceText,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const ShadowingEvaluation(
      score: 86,
      feedback: '已完成录音，后续可在这里接入后端语音评测。',
    );
  }

  Future<void> dispose() => _recorder.dispose();
}

class ShadowingEvaluation {
  const ShadowingEvaluation({required this.score, required this.feedback});

  final int score;
  final String feedback;
}
