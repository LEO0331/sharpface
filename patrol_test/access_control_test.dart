import 'package:flutter/widgets.dart';
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
  patrolTest('drawer hides history/admin for logged-out user', ($) async {
    await app.main();
    await $.pumpAndSettle();

    await $.tester.tap(find.byTooltip('Open navigation menu'));
    await $.pumpAndSettle();

    expect(_textEither('我的最愛', 'Favorites'), findsOneWidget);
    expect(_textEither('歷史膚質曲線', 'Skin Trend'), findsNothing);
    expect(_textEither('管理後台', 'Admin Dashboard'), findsNothing);
    expect(_textEither('登入 / 註冊', 'Login / Register'), findsOneWidget);
  });
}
