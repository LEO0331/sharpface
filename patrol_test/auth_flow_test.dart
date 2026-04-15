import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:sharpface/main.dart' as app;

void main() {
  patrolTest('auth page navigation and form interaction', ($) async {
    app.main();
    await $.pumpAndSettle();

    await $.tester.tap(find.byTooltip('Open navigation menu'));
    await $.pumpAndSettle();

    await $('登入 / 註冊').tap();
    await $.pumpAndSettle();

    expect($('登入 / 註冊'), findsWidgets);
    expect($('歡迎回來'), findsOneWidget);

    final loginEmail = find.byType(TextField).at(0);
    final loginPassword = find.byType(TextField).at(1);
    await $.tester.enterText(loginEmail, 'tester@example.com');
    await $.tester.enterText(loginPassword, '123456');
    await $.pumpAndSettle();

    await $('註冊').tap();
    await $.pumpAndSettle();

    final registerEmail = find.byType(TextField).at(2);
    final registerPassword = find.byType(TextField).at(3);
    final registerPhone = find.byType(TextField).at(4);
    await $.tester.enterText(registerEmail, 'newuser@example.com');
    await $.tester.enterText(registerPassword, '123456');
    await $.tester.enterText(registerPhone, '+886900000005');
    await $.pumpAndSettle();

    expect($('登入或註冊後可跨裝置同步收藏與紀錄。'), findsOneWidget);
  });
}
