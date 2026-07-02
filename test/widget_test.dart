import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_catcher/src/app.dart';

void main() {
  testWidgets('WordCatcher home renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WordCatcherApp()));

    expect(find.text('拍沃德 WordCatcher'), findsOneWidget);
    expect(find.text('拍照识别'), findsOneWidget);
    expect(find.text('相册选择'), findsOneWidget);
  });
}
