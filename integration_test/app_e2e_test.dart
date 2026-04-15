import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sharpface/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home e2e smoke flow', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('男士 AI 護膚分析儀'), findsWidgets);

    await tester.tap(find.byIcon(Icons.speed_outlined).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('動效節奏切換為'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '不存在產品');
    await tester.pumpAndSettle();
    expect(find.text('查無符合條件的產品。'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('我的最愛'), findsOneWidget);

    await tester.tap(find.text('我的最愛'));
    await tester.pumpAndSettle();
    expect(find.text('目前尚未加入任何最愛商品。'), findsOneWidget);
  });
}
