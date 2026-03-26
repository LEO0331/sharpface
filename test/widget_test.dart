import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/widgets/top_care_guide_card.dart';

void main() {
  testWidgets('Top care guide renders content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TopCareGuideCard(
            skinType: '混合肌',
            suggestion: '加強保濕與白天防曬。',
          ),
        ),
      ),
    );

    expect(find.text('基礎早晚保養步驟'), findsOneWidget);
    expect(find.textContaining('混合肌'), findsOneWidget);
  });
}
