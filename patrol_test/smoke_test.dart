import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:sharpface/main.dart' as app;

void main() {
  patrolTest('app smoke flow', ($) async {
    app.main();
    await $.pumpAndSettle();

    expect($('男士 AI 護膚分析儀'), findsWidgets);

    await $(Icons.speed_outlined).tap();
    await $.pumpAndSettle();
    expect($('動效節奏切換為'), findsOneWidget);

    await $(TextField).first.enterText('不存在產品');
    await $.pumpAndSettle();
    expect($('查無符合條件的產品。'), findsOneWidget);

    await $.tester.tap(find.byTooltip('Open navigation menu'));
    await $.pumpAndSettle();
    expect($('我的最愛'), findsOneWidget);
  });
}
