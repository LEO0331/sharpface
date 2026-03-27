import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/services/ads_service.dart';

void main() {
  group('AdsService', () {
    late FakeFirebaseFirestore firestore;
    late AdsService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = AdsService(firestore: firestore);
    });

    test('save/get/watch pool config works', () async {
      await service.savePoolConfig(
        const AdPoolConfig(
          pool: 'general',
          messages: ['hello'],
          enabled: true,
          priority: 10,
        ),
      );

      final once = await service.getPoolConfigOnce('general');
      expect(once.messages, ['hello']);
      expect(once.enabled, isTrue);
      expect(once.priority, 10);

      final watched = await service.watchPoolConfig('general').first;
      expect(watched.pool, 'general');
      expect(watched.messages.first, 'hello');
    });

    test('draft save/get and publish writes history', () async {
      await service.savePoolConfig(
        const AdPoolConfig(
          pool: 'acne',
          messages: ['old'],
          enabled: true,
          priority: 50,
        ),
      );

      await service.saveDraftConfig(
        const AdPoolConfig(
          pool: 'acne',
          messages: ['new1', 'new2'],
          enabled: false,
          priority: 200,
        ),
      );
      final draft = await service.getDraftConfigOnce('acne');
      expect(draft.messages.length, 2);
      expect(draft.enabled, isFalse);
      expect(draft.priority, 200);

      await service.publishPoolConfig(draft);
      final live = await service.getPoolConfigOnce('acne');
      expect(live.messages.first, 'new1');
      expect(live.priority, 200);

      final history = await service.getPoolHistory('acne');
      expect(history, isNotEmpty);
      expect(history.first.messages.first, 'old');
    });

    test('track impressions/clicks updates adStats and ctr', () async {
      await service.trackAdImpression(
        pool: 'general',
        message: 'ad-x',
        userId: 'u1',
      );
      await service.trackAdImpression(
        pool: 'general',
        message: 'ad-x',
        userId: 'u2',
      );
      await service.trackAdClick(
        pool: 'general',
        message: 'ad-x',
        userId: 'u1',
      );

      final stats = await firestore.collection('adStats').get();
      expect(stats.docs.length, 1);
      final data = stats.docs.first.data();
      expect(data['impressions'], 2);
      expect(data['clicks'], 1);
      expect((data['ctr'] as num).toDouble(), 0.5);

      final events = await firestore.collection('adEvents').get();
      expect(events.docs.length, 3);
    });

    test('isActiveAt respects scheduling window', () {
      final now = DateTime.now();
      final active = AdPoolConfig(
        pool: 'general',
        messages: const ['a'],
        enabled: true,
        priority: 1,
        startAt: now.subtract(const Duration(minutes: 1)),
        endAt: now.add(const Duration(minutes: 1)),
      );
      final inactive = AdPoolConfig(
        pool: 'general',
        messages: const ['a'],
        enabled: true,
        priority: 1,
        startAt: now.add(const Duration(hours: 1)),
        endAt: now.add(const Duration(hours: 2)),
      );

      expect(active.isActiveAt(now), isTrue);
      expect(inactive.isActiveAt(now), isFalse);
    });
  });
}
