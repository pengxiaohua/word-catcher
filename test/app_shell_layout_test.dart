import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_catcher/src/app.dart';

void main() {
  testWidgets(
    'page scrolls behind the floating navigation on a compact screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: WordCatcherApp()));
      await tester.pump(const Duration(milliseconds: 700));

      final homeScrollView = find.byType(Scrollable).first;
      final selectedTabIndicator = find.ancestor(
        of: find.text('首页'),
        matching: find.byType(AnimatedContainer),
      );

      final scrollViewBottom = tester.getBottomRight(homeScrollView).dy;
      final navigationTop = tester.getTopLeft(selectedTabIndicator).dy;

      expect(scrollViewBottom, greaterThan(navigationTop));
      expect(tester.takeException(), isNull);
    },
  );
}
