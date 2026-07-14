import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_config.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/scan_history_item.dart';

final historyApiServiceProvider = Provider<HistoryApiService>((ref) {
  return HistoryApiService(
    ref.watch(dioProvider),
    useMockApi: AppConfig.useMockApi,
  );
});

final historyProvider = FutureProvider.autoDispose<List<ScanHistoryItem>>((
  ref,
) async {
  return ref.watch(historyApiServiceProvider).fetchHistory();
});

class HistoryApiService {
  const HistoryApiService(this._dio, {required this.useMockApi});

  final Dio _dio;
  final bool useMockApi;

  Future<List<ScanHistoryItem>> fetchHistory() async {
    if (useMockApi) {
      return _mockHistory();
    }

    final response = await _dio.get<Object?>('/api/history');
    final data = response.data;
    final items = data is Map ? data['items'] : data;
    if (items is! List) {
      throw StateError('History API returned an unexpected payload.');
    }

    return items
        .whereType<Map>()
        .map(
          (item) => ScanHistoryItem.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList(growable: false);
  }

  Future<List<ScanHistoryItem>> _mockHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    return [
      {
        'id': 'history-1',
        'imageUrl': 'https://picsum.photos/seed/camera/240/240',
        'sourceWord': 'camera',
        'wordCategory': 'DIGITAL_DEVICES',
        'sentenceDifficulty': 'A1',
        'phonetics': {'uk': '/ˈkæmərə/', 'us': '/ˈkæmərə/'},
        'translations': {'中文': '相机'},
        'sentences': [
          {
            'english': 'I use a camera to capture quiet moments.',
            'translation': '我用相机记录安静的时刻。',
          },
        ],
        'audioLinks': {
          'uk': 'https://oss.mock.wordcatcher.app/tts/uk/camera.mp3',
          'us': 'https://oss.mock.wordcatcher.app/tts/us/camera.mp3',
        },
        'createdAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'history-2',
        'imageUrl': 'https://picsum.photos/seed/notebook/240/240',
        'sourceWord': 'notebook',
        'wordCategory': 'SCHOOL_OFFICE',
        'sentenceDifficulty': 'A2',
        'phonetics': {'uk': '/ˈnəʊtbʊk/', 'us': '/ˈnoʊtbʊk/'},
        'translations': {'中文': '笔记本'},
        'sentences': [
          {
            'english': 'This notebook keeps my tiny word discoveries.',
            'translation': '这个笔记本收藏我的小小单词发现。',
          },
        ],
        'audioLinks': {
          'uk': 'https://oss.mock.wordcatcher.app/tts/uk/notebook.mp3',
          'us': 'https://oss.mock.wordcatcher.app/tts/us/notebook.mp3',
        },
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'history-3',
        'imageUrl': 'https://picsum.photos/seed/bottle/240/240',
        'sourceWord': 'bottle',
        'wordCategory': 'HOME_LIVING',
        'sentenceDifficulty': 'B1',
        'phonetics': {'uk': '/ˈbɒtl/', 'us': '/ˈbɑːtl/'},
        'translations': {'中文': '瓶子'},
        'sentences': [
          {
            'english': 'A small bottle sits beside the book.',
            'translation': '一个小瓶子放在书旁边。',
          },
        ],
        'audioLinks': {
          'uk': 'https://oss.mock.wordcatcher.app/tts/uk/bottle.mp3',
          'us': 'https://oss.mock.wordcatcher.app/tts/us/bottle.mp3',
        },
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
      },
    ].map(ScanHistoryItem.fromJson).toList(growable: false);
  }
}
