import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/services/admin_service.dart';

void main() {
  group('AdminService', () {
    late FakeFirebaseFirestore firestore;
    late AdminService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = AdminService(firestore);
    });

    test('fetchStats computes top ad ctr from adEvents', () async {
      await firestore.collection('users').doc('u1').set({'role': 'user'});
      await firestore.collection('scanRecords').add({
        'userId': 'u1',
        'skinType': '油性肌',
        'createdAt': DateTime.now(),
      });
      await firestore.collection('products').doc('p1').set({
        'name': 'Top Product',
        'clickCount': 8,
      });
      await firestore.collection('products').doc('p2').set({
        'name': 'Other Product',
        'clickCount': 3,
      });

      for (var i = 0; i < 4; i++) {
        await firestore.collection('adEvents').add({
          'adId': 'ad_a',
          'message': 'A',
          'type': 'impression',
          'createdAt': DateTime.now(),
        });
      }
      for (var i = 0; i < 2; i++) {
        await firestore.collection('adEvents').add({
          'adId': 'ad_a',
          'message': 'A',
          'type': 'click',
          'createdAt': DateTime.now(),
        });
      }

      for (var i = 0; i < 5; i++) {
        await firestore.collection('adEvents').add({
          'adId': 'ad_b',
          'message': 'B',
          'type': 'impression',
          'createdAt': DateTime.now(),
        });
      }
      await firestore.collection('adEvents').add({
        'adId': 'ad_b',
        'message': 'B',
        'type': 'click',
        'createdAt': DateTime.now(),
      });

      final stats = await service.fetchStats();
      expect(stats.topProductName, 'Top Product');
      expect(stats.topAdMessage, 'A');
      expect(stats.topAdCtr, 0.5);
    });

    test(
      'fetchStats returns no-data fallback when collections empty',
      () async {
        final stats = await service.fetchStats();
        expect(stats.totalUsers, 0);
        expect(stats.todayScans, 0);
        expect(stats.topProductName, 'No data');
        expect(stats.topAdMessage, 'No data');
        expect(stats.topAdCtr, 0);
      },
    );

    test('top ad picks higher impressions when ctr is tied', () async {
      await firestore.collection('products').doc('p').set({
        'name': 'Any Product',
        'clickCount': 1,
      });

      for (var i = 0; i < 2; i++) {
        await firestore.collection('adEvents').add({
          'adId': 'ad_small',
          'message': 'Small CTR Pool',
          'type': 'impression',
          'createdAt': DateTime.now(),
        });
      }
      await firestore.collection('adEvents').add({
        'adId': 'ad_small',
        'message': 'Small CTR Pool',
        'type': 'click',
        'createdAt': DateTime.now(),
      });

      for (var i = 0; i < 4; i++) {
        await firestore.collection('adEvents').add({
          'adId': 'ad_big',
          'message': 'Big CTR Pool',
          'type': 'impression',
          'createdAt': DateTime.now(),
        });
      }
      for (var i = 0; i < 2; i++) {
        await firestore.collection('adEvents').add({
          'adId': 'ad_big',
          'message': 'Big CTR Pool',
          'type': 'click',
          'createdAt': DateTime.now(),
        });
      }

      final stats = await service.fetchStats();
      expect(stats.topAdMessage, 'Big CTR Pool');
      expect(stats.topAdCtr, 0.5);
    });

    test('ad events with missing impression return no ad data', () async {
      await firestore.collection('products').doc('p').set({
        'name': 'Any Product',
        'clickCount': 1,
      });
      await firestore.collection('adEvents').add({
        'adId': 'click_only',
        'message': 'Click Only',
        'type': 'click',
        'createdAt': DateTime.now(),
      });

      final stats = await service.fetchStats();
      expect(stats.topAdMessage, 'No data');
      expect(stats.topAdCtr, 0);
    });
  });
}
