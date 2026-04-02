import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/widgets/ui/motion_system.dart';

void main() {
  tearDown(() {
    AppMotion.profileNotifier.value = MotionPreset.balanced;
  });

  test('cyclePreset rotates through relaxed/balanced/snappy', () {
    AppMotion.profileNotifier.value = MotionPreset.relaxed;
    expect(AppMotion.cyclePreset(), MotionPreset.balanced);
    expect(AppMotion.cyclePreset(), MotionPreset.snappy);
    expect(AppMotion.cyclePreset(), MotionPreset.relaxed);
  });

  test('durations follow preset profile', () {
    AppMotion.profileNotifier.value = MotionPreset.relaxed;
    expect(AppMotion.pageEnter, const Duration(milliseconds: 520));
    expect(AppMotion.staggerStep, const Duration(milliseconds: 120));

    AppMotion.profileNotifier.value = MotionPreset.snappy;
    expect(AppMotion.pageEnter, const Duration(milliseconds: 220));
    expect(AppMotion.hover, const Duration(milliseconds: 120));
  });

  testWidgets('MotionPresetSwitcherButton cycles and shows snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: MotionPresetSwitcherButton())),
      ),
    );

    expect(AppMotion.profile, MotionPreset.balanced);
    await tester.tap(find.byIcon(Icons.speed_outlined));
    await tester.pump();
    expect(AppMotion.profile, MotionPreset.snappy);
    expect(find.textContaining('snappy'), findsOneWidget);
  });

  testWidgets('PageEnterTransition and StaggerReveal render child', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PageEnterTransition(
            child: Column(
              children: [
                MotionReveal(visible: true, child: Text('always-visible')),
                StaggerReveal(index: 1, child: Text('stagger-visible')),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('always-visible'), findsOneWidget);
    expect(find.text('stagger-visible'), findsOneWidget);
  });
}
