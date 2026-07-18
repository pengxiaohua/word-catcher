import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_catcher/src/features/history/data/history_api_service.dart';
import 'package:word_catcher/src/features/history/domain/scan_history_item.dart';
import 'package:word_catcher/src/app.dart';

void main() {
  testWidgets('WordCatcher home renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WordCatcherApp()));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('拍照识物，学会英语'), findsOneWidget);
    expect(find.text('拍照识别'), findsOneWidget);
    expect(find.text('相册选择'), findsOneWidget);
  });

  testWidgets('learning tab refetches history when selected', (tester) async {
    final historyApi = _FakeHistoryApiService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [historyApiServiceProvider.overrideWithValue(historyApi)],
        child: const WordCatcherApp(),
      ),
    );
    await tester.pump();

    expect(historyApi.fetchCount, 1);

    await tester.tap(find.text('学习'));
    await tester.pump();

    expect(historyApi.fetchCount, 2);

    await tester.tap(find.text('首页'));
    await tester.pump();
    await tester.tap(find.text('学习'));
    await tester.pump();

    expect(historyApi.fetchCount, 3);

    await tester.tap(find.text('学习'));
    await tester.pump();

    expect(historyApi.fetchCount, 4);
  });
}

class _FakeHistoryApiService implements HistoryApiService {
  int fetchCount = 0;

  @override
  bool get useMockApi => true;

  @override
  Future<List<ScanHistoryItem>> fetchHistory() async {
    fetchCount += 1;
    return const <ScanHistoryItem>[];
  }
}
