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
  patrolTest('auth page navigation and form interaction', ($) async {
    await app.main();
    await $.pumpAndSettle();

    await $.tester.tap(find.byTooltip('Open navigation menu'));
    await $.pumpAndSettle();

    await $.tester.tap(_textEither('登入 / 註冊', 'Login / Register').first);
    await $.pumpAndSettle();

    expect(_textEither('登入 / 註冊', 'Login / Register'), findsWidgets);
    expect($('歡迎回來'), findsOneWidget);

    final loginFields = find.byType(TextField);
    expect(loginFields, findsAtLeastNWidgets(2));
    final loginEmail = loginFields.at(0);
    final loginPassword = loginFields.at(1);
    await $.tester.enterText(loginEmail, 'tester@example.com');
    await $.tester.enterText(loginPassword, '123456');
    await $.pumpAndSettle();

    await $.tester.tap(find.widgetWithText(Tab, '註冊'));
    await $.pumpAndSettle();

    expect(find.text('密碼（至少 6 碼）'), findsOneWidget);

    final registerFields = find.byType(TextField);
    final registerFieldCount = registerFields.evaluate().length;
    expect(registerFieldCount, greaterThanOrEqualTo(2));

    final registerEmail = registerFields.at(0);
    final registerPassword = registerFields.at(1);
    await $.tester.enterText(registerEmail, 'newuser@example.com');
    await $.tester.enterText(registerPassword, '123456');
    if (registerFieldCount > 2) {
      final registerPhone = registerFields.at(2);
      await $.tester.enterText(registerPhone, '+886900000005');
    }
    await $.pumpAndSettle();

    expect($('登入或註冊後可跨裝置同步收藏與紀錄。'), findsOneWidget);
  });
}
