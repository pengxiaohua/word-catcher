import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/app_config.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/analyze_result.dart';
import 'image_request_optimizer.dart';

final scanApiServiceProvider = Provider<ScanApiService>((ref) {
  return ScanApiService(
    ref.watch(dioProvider),
    ref.watch(imageRequestOptimizerProvider),
    useMockApi: AppConfig.useMockApi,
  );
});

class ScanApiService {
  const ScanApiService(
    this._dio,
    this._imageOptimizer, {
    required this.useMockApi,
  });

  final Dio _dio;
  final ImageRequestOptimizer _imageOptimizer;
  final bool useMockApi;

  Future<PreparedScanImage> prepareImage(XFile image) async {
    final payload = await _imageOptimizer.optimize(image);
    return PreparedScanImage(displayImageUrl: image.path, payload: payload);
  }

  Future<AnalyzeResult> analyzeImage({
    required PreparedScanImage image,
    required String targetLanguage,
    required String sentenceVoiceId,
    required String sentenceDifficulty,
  }) async {
    if (useMockApi) {
      return _mockAnalyzeResult(
        image.displayImageUrl,
        sentenceVoiceId,
        sentenceDifficulty,
      );
    }

    try {
      final response = await _dio.post<Object?>(
        '/api/analyze-image',
        data: {
          'imageDataUrl': image.payload.dataUrl,
          'targetLanguage': targetLanguage,
          'sentenceVoiceId': sentenceVoiceId,
          'sentenceDifficulty': sentenceDifficulty,
          'imageMeta': {
            'mimeType': image.payload.mimeType,
            'byteSize': image.payload.byteSize,
            'width': image.payload.width,
            'height': image.payload.height,
          },
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw StateError('服务端返回的数据格式不正确，请再试一次。');
      }

      return AnalyzeResult.fromJson(
        data.map((key, value) => MapEntry(key.toString(), value)),
      );
    } on DioException catch (error) {
      throw StateError(_friendlyDioError(error));
    }
  }

  String _friendlyDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      final message = _responseMessage(error.response?.data);
      final detail = message.isEmpty ? '' : '：$message';
      return '服务端识别失败（$statusCode）$detail';
    }

    return '连接服务端失败：${_dio.options.baseUrl}。请确认手机能访问这个地址，并重新安装带 dart-define 的 App。原始错误：${error.message}';
  }

  String _responseMessage(Object? data) {
    if (data is Map) {
      final value = data['message'] ?? data['error'];
      return value?.toString() ?? '';
    }
    return data?.toString() ?? '';
  }

  Future<AnalyzeResult> _mockAnalyzeResult(
    String imageUrl,
    String sentenceVoiceId,
    String sentenceDifficulty,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    const translations = <String, String>{'中文': '相机'};
    final voicePath = sentenceVoiceId.trim().isEmpty
        ? 'English_Upbeat_Woman'
        : sentenceVoiceId;

    return AnalyzeResult.fromJson({
      'id': 'mock-scan-${DateTime.now().millisecondsSinceEpoch}',
      'imageUrl': imageUrl,
      'sourceWord': 'camera',
      'wordCategory': 'DIGITAL_DEVICES',
      'sentenceDifficulty': sentenceDifficulty,
      'phonetics': {'uk': '/ˈkæmərə/', 'us': '/ˈkæmərə/'},
      'translations': translations,
      'sentences': _mockSentences(sentenceDifficulty, voicePath),
      'audioLinks': {
        'uk':
            'https://oss.mock.wordcatcher.app/tts/English_compelling_lady1/camera.mp3',
        'us':
            'https://oss.mock.wordcatcher.app/tts/English_Upbeat_Woman/camera.mp3',
      },
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, String>> _mockSentences(
    String sentenceDifficulty,
    String voicePath,
  ) {
    final sentences = switch (sentenceDifficulty.trim().toUpperCase()) {
      'A2' => [
        ('I use a camera on weekends.', '我周末使用相机。'),
        ('The camera is on the wooden desk.', '相机在木桌上。'),
        ('She bought a small camera for travel.', '她买了一台旅行用的小相机。'),
      ],
      'B1' => [
        ('I use a camera to capture quiet moments.', '我用相机记录安静的时刻。'),
        (
          'The camera helps me remember places I have visited.',
          '相机帮助我记住去过的地方。',
        ),
        (
          'Although it is small, this camera takes clear photos.',
          '虽然它很小，这台相机能拍出清晰的照片。',
        ),
      ],
      'B2' => [
        (
          'A camera can turn an ordinary afternoon into a lasting memory.',
          '相机能把一个普通的下午变成持久的记忆。',
        ),
        (
          'This compact camera is useful when a phone feels too casual.',
          '当手机显得太随意时，这台小相机很有用。',
        ),
        (
          'With careful framing, the camera makes simple objects feel poetic.',
          '通过仔细构图，相机会让简单物品显得富有诗意。',
        ),
      ],
      _ => [
        ('This is a camera.', '这是一台相机。'),
        ('The camera is black.', '这台相机是黑色的。'),
        ('I like this camera.', '我喜欢这台相机。'),
      ],
    };

    return [
      for (var index = 0; index < sentences.length; index++)
        {
          'english': sentences[index].$1,
          'translation': sentences[index].$2,
          'audioUrl':
              'https://oss.mock.wordcatcher.app/tts/$voicePath/camera-${index + 1}.mp3',
        },
    ];
  }
}

class PreparedScanImage {
  const PreparedScanImage({
    required this.displayImageUrl,
    required this.payload,
  });

  final String displayImageUrl;
  final OptimizedImagePayload payload;
}
