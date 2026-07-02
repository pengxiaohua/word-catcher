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
  }) async {
    if (useMockApi) {
      return _mockAnalyzeResult(image.displayImageUrl, sentenceVoiceId);
    }

    try {
      final response = await _dio.post<Object?>(
        '/api/analyze-image',
        data: {
          'imageDataUrl': image.payload.dataUrl,
          'targetLanguage': targetLanguage,
          'sentenceVoiceId': sentenceVoiceId,
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
      'phonetics': {'uk': '/ˈkæmərə/', 'us': '/ˈkæmərə/'},
      'translations': translations,
      'sentences': [
        {
          'english': 'I use a camera to capture quiet moments.',
          'translation': '我用相机记录安静的时刻。',
          'audioUrl':
              'https://oss.mock.wordcatcher.app/tts/$voicePath/camera-1.mp3',
        },
        {
          'english': 'The camera is on the wooden desk.',
          'translation': '相机在木桌上。',
          'audioUrl':
              'https://oss.mock.wordcatcher.app/tts/$voicePath/camera-2.mp3',
        },
        {
          'english': 'She bought a small camera for travel.',
          'translation': '她买了一台旅行用的小相机。',
          'audioUrl':
              'https://oss.mock.wordcatcher.app/tts/$voicePath/camera-3.mp3',
        },
      ],
      'audioLinks': {
        'uk':
            'https://oss.mock.wordcatcher.app/tts/English_compelling_lady1/camera.mp3',
        'us':
            'https://oss.mock.wordcatcher.app/tts/English_Upbeat_Woman/camera.mp3',
      },
      'createdAt': DateTime.now().toIso8601String(),
    });
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
