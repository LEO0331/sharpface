import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:sharpface/main.dart' as app;

Finder _textEither(String zh, String en) {
  return find.byWidgetPredicate((widget) {
    if (widget is! Text) return false;
    final data = widget.data ?? '';
    return data.contains(zh) || data.contains(en);
  });
}

void main() {
  patrolTest('app smoke flow', ($) async {
    await app.main();
    await $.pumpAndSettle();
    expect(find.byIcon(Icons.speed_outlined), findsOneWidget);

    await $(Icons.speed_outlined).tap();
    await $.pumpAndSettle();
    expect(_textEither('動效節奏切換為', 'Motion preset switched to'), findsOneWidget);

    await $(TextField).first.enterText('不存在產品');
    await $.pumpAndSettle();
    expect(
      _textEither('查無符合條件的產品。', 'No matching products found.'),
      findsOneWidget,
    );

    await $.tester.tap(find.byTooltip('Open navigation menu'));
    await $.pumpAndSettle();
    expect(_textEither('我的最愛', 'Favorites'), findsOneWidget);
  });
}
