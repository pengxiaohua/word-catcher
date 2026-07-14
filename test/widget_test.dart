import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_catcher/src/app.dart';

void main() {
  testWidgets('WordCatcher home renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WordCatcherApp()));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('拍照识物，学会英语'), findsOneWidget);
    expect(find.text('拍照识别'), findsOneWidget);
    expect(find.text('相册选择'), findsOneWidget);
  });
}
