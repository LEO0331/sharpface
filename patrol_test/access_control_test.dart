import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:sharpface/main.dart' as app;

void main() {
  patrolTest('drawer hides history/admin for logged-out user', ($) async {
    app.main();
    await $.pumpAndSettle();

    await $.tester.tap(find.byTooltip('Open navigation menu'));
    await $.pumpAndSettle();

    expect($('我的最愛'), findsOneWidget);
    expect($('歷史膚質曲線'), findsNothing);
    expect($('管理後台'), findsNothing);
    expect($('登入 / 註冊'), findsOneWidget);
  });
}
