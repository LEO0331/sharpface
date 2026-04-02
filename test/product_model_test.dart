import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/models/product.dart';

void main() {
  group('Product model', () {
    test('fromFirestore maps all fields and clamps rating', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('products').doc('p1').set({
        'name': 'Serum A',
        'price': 399,
        'mainIngredients': ['B5', 'Niacinamide'],
        'rating': 9,
        'affiliateUrl': 'https://example.com/p1',
        'isFeatured': true,
        'clickCount': 7,
        'imageUrl': 'https://img/p1.jpg',
        'userScore': 4.6,
        'reviewCount': 88,
      });

      final snap = await firestore.collection('products').doc('p1').get();
      final product = Product.fromFirestore(snap);

      expect(product.id, 'p1');
      expect(product.name, 'Serum A');
      expect(product.price, 399);
      expect(product.mainIngredients, ['B5', 'Niacinamide']);
      expect(product.rating, 3);
      expect(product.affiliateUrl, 'https://example.com/p1');
      expect(product.isFeatured, isTrue);
      expect(product.clickCount, 7);
      expect(product.imageUrl, isNotNull);
      expect(product.userScore, 4.6);
      expect(product.reviewCount, 88);
    });

    test('fromFirestore provides defaults for missing fields', () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('products').doc('p2').set({});

      final snap = await firestore.collection('products').doc('p2').get();
      final product = Product.fromFirestore(snap);

      expect(product.id, 'p2');
      expect(product.name, '');
      expect(product.price, 0);
      expect(product.mainIngredients, isEmpty);
      expect(product.rating, 1);
      expect(product.affiliateUrl, '');
      expect(product.isFeatured, isFalse);
      expect(product.clickCount, 0);
      expect(product.imageUrl, isNull);
      expect(product.userScore, isNull);
      expect(product.reviewCount, isNull);
    });

    test('toFirestore serializes optional fields', () {
      const product = Product(
        id: 'x1',
        name: 'Cleanser',
        price: 280,
        mainIngredients: ['AHA'],
        rating: 2,
        affiliateUrl: 'https://example.com/c',
        isFeatured: false,
        clickCount: 3,
        imageUrl: 'https://img/c.jpg',
        userScore: 4.2,
        reviewCount: 12,
      );

      final data = product.toFirestore();
      expect(data['name'], 'Cleanser');
      expect(data['price'], 280);
      expect(data['mainIngredients'], ['AHA']);
      expect(data['rating'], 2);
      expect(data['affiliateUrl'], 'https://example.com/c');
      expect(data['isFeatured'], false);
      expect(data['clickCount'], 3);
      expect(data['imageUrl'], 'https://img/c.jpg');
      expect(data['userScore'], 4.2);
      expect(data['reviewCount'], 12);
    });
  });
}
