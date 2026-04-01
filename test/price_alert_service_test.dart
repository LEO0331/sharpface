import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/models/product.dart';
import 'package:sharpface/services/price_alert_service.dart';

void main() {
  group('PriceAlertService', () {
    late FakeFirebaseFirestore firestore;
    late PriceAlertService service;

    const uid = 'u1';
    const product = Product(
      id: 'p1',
      name: 'Alert Product',
      price: 1000,
      mainIngredients: ['A'],
      rating: 2,
      affiliateUrl: 'https://example.com',
      isFeatured: false,
      clickCount: 0,
    );

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = PriceAlertService(firestore: firestore);
    });

    test('upsert and hasAlert work', () async {
      final before = await service.hasAlert(uid: uid, productId: product.id);
      expect(before, isFalse);

      await service.upsertAlert(uid: uid, product: product, targetPrice: 899);
      final after = await service.hasAlert(uid: uid, productId: product.id);
      expect(after, isTrue);
    });

    test('removeAlert deletes alert', () async {
      await service.upsertAlert(uid: uid, product: product, targetPrice: 899);
      await service.removeAlert(uid: uid, productId: product.id);
      final exists = await service.hasAlert(uid: uid, productId: product.id);
      expect(exists, isFalse);
    });
  });
}
