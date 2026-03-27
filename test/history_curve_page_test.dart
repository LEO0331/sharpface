import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/models/scan_record.dart';
import 'package:sharpface/screens/history_curve_page.dart';

void main() {
  testWidgets('shows no record message for empty stream', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HistoryCurvePage(
          userId: 'u1',
          recordsStream: Stream.value(const []),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('目前沒有掃描紀錄。'), findsOneWidget);
  });

  testWidgets('shows chips and trend title for records', (tester) async {
    final records = [
      ScanRecord(
        id: 's1',
        userId: 'u1',
        skinType: '混合肌',
        suggestion: '保濕',
        concerns: const ['痘痘'],
        createdAt: DateTime(2026, 3, 20),
      ),
      ScanRecord(
        id: 's2',
        userId: 'u1',
        skinType: '油性肌',
        suggestion: '控油',
        concerns: const ['黑眼圈', '痘痘'],
        createdAt: DateTime(2026, 3, 22),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: HistoryCurvePage(
          userId: 'u1',
          recordsStream: Stream<List<ScanRecord>>.fromIterable([records]),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('7 天'), findsOneWidget);
    expect(find.text('30 天'), findsOneWidget);
    expect(find.text('全部'), findsOneWidget);

    await tester.tap(find.text('30 天'));
    await tester.pumpAndSettle();
    expect(find.textContaining('近 2 次膚況趨勢'), findsOneWidget);
  });

  testWidgets('switch filter chip updates displayed count', (tester) async {
    final records = [
      ScanRecord(
        id: 'old',
        userId: 'u1',
        skinType: '乾性肌',
        suggestion: '保濕',
        concerns: const ['乾燥'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      ScanRecord(
        id: 'new',
        userId: 'u1',
        skinType: '混合肌',
        suggestion: '防曬',
        concerns: const ['痘痘'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    final controller = StreamController<List<ScanRecord>>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      MaterialApp(
        home: HistoryCurvePage(
          userId: 'u1',
          recordsStream: controller.stream,
        ),
      ),
    );

    controller.add(records);
    await tester.pumpAndSettle();

    expect(find.textContaining('近 1 次膚況趨勢'), findsOneWidget);

    await tester.tap(find.text('30 天'));
    await tester.pumpAndSettle();

    expect(find.textContaining('近 2 次膚況趨勢'), findsOneWidget);
  });
}
