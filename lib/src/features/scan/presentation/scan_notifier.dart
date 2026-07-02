import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../data/media_service.dart';
import '../data/scan_api_service.dart';
import '../domain/analyze_result.dart';

final scanNotifierProvider = NotifierProvider<ScanNotifier, ScanState>(
  ScanNotifier.new,
);

class ScanNotifier extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  Future<void> analyzeFrom({
    required ImageSource source,
    required String targetLanguage,
    required String sentenceVoiceId,
  }) async {
    try {
      state = const ScanState(status: ScanStatus.picking);
      final image = await ref.read(mediaServiceProvider).pickImage(source);
      if (image == null) {
        state = const ScanState();
        return;
      }

      state = ScanState(
        status: ScanStatus.preparing,
        localImagePath: image.path,
      );
      final preparedImage = await ref
          .read(scanApiServiceProvider)
          .prepareImage(image);

      state = ScanState(
        status: ScanStatus.analyzing,
        localImagePath: image.path,
      );
      final result = await ref
          .read(scanApiServiceProvider)
          .analyzeImage(
            image: preparedImage,
            targetLanguage: targetLanguage,
            sentenceVoiceId: sentenceVoiceId,
          );

      state = ScanState(
        status: ScanStatus.success,
        result: result,
        localImagePath: image.path,
      );
    } catch (error) {
      state = ScanState(
        status: ScanStatus.failure,
        errorMessage: _friendlyError(error),
        localImagePath: state.localImagePath,
      );
    }
  }

  void reset() {
    state = const ScanState();
  }

  String _friendlyError(Object error) {
    return error
        .toString()
        .replaceFirst('Bad state: ', '')
        .replaceFirst('Exception: ', '')
        .trim();
  }
}

enum ScanStatus { idle, picking, preparing, analyzing, success, failure }

class ScanState {
  const ScanState({
    this.status = ScanStatus.idle,
    this.result,
    this.errorMessage,
    this.localImagePath,
  });

  final ScanStatus status;
  final AnalyzeResult? result;
  final String? errorMessage;
  final String? localImagePath;

  bool get isLoading => switch (status) {
    ScanStatus.picking || ScanStatus.preparing || ScanStatus.analyzing => true,
    _ => false,
  };

  String get loadingLabel => switch (status) {
    ScanStatus.picking => '正在打开媒体库',
    ScanStatus.preparing => '正在压缩图片',
    ScanStatus.analyzing => '正在识别单词',
    _ => '',
  };
}
