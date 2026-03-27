import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharpface/models/product.dart';
import 'package:sharpface/services/favorite_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoriteService', () {
    late FakeFirebaseFirestore firestore;
    late FavoriteService service;

    const uid = 'u1';
    const product = Product(
      id: 'p1',
      name: 'Cleanser',
      price: 200,
      mainIngredients: ['AHA'],
      rating: 2,
      affiliateUrl: 'https://example.com',
      isFeatured: false,
      clickCount: 0,
      imageUrl: 'https://picsum.photos/200',
      userScore: 4.2,
      reviewCount: 12,
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      firestore = FakeFirebaseFirestore();
      service = FavoriteService(firestore: firestore);
    });

    test('readCachedFavorites returns empty when cache missing', () async {
      final cached = await service.readCachedFavorites(uid);
      expect(cached, isEmpty);
    });

    test('watchFavorites emits data and writes cache', () async {
      await service.addFavorite(uid: uid, product: product);

      final watched = await service.watchFavorites(uid).first;
      expect(watched.length, 1);
      expect(watched.first.name, 'Cleanser');

      final cached = await service.readCachedFavorites(uid);
      expect(cached.length, 1);
      expect(cached.first.id, 'p1');
      expect(cached.first.imageUrl, isNotNull);
    });

    test('removeFavorite deletes from firestore favorites', () async {
      await service.addFavorite(uid: uid, product: product);
      await service.removeFavorite(uid: uid, productId: product.id);

      final snap =
          await firestore.collection('users').doc(uid).collection('favorites').get();
      expect(snap.docs, isEmpty);
    });
  });
}
