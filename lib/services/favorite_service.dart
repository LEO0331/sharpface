import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/cache/local_cache_service.dart';
import '../models/product.dart';

class FavoriteService {
  FavoriteService({
    FirebaseFirestore? firestore,
    LocalCacheService? cache,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _cache = cache ?? LocalCacheService();

  final FirebaseFirestore _firestore;
  final LocalCacheService _cache;
  static const Duration _cacheTtl = Duration(minutes: 10);

  Stream<List<Product>> watchFavorites(String uid) {
    final stream = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: (data['name'] as String?) ?? '',
          price: ((data['price'] as num?) ?? 0).toDouble(),
          mainIngredients: List<String>.from(data['mainIngredients'] ?? const []),
          rating: ((data['rating'] as num?) ?? 1).clamp(1, 3).toInt(),
          affiliateUrl: (data['affiliateUrl'] as String?) ?? '',
          isFeatured: (data['isFeatured'] as bool?) ?? false,
          clickCount: (data['clickCount'] as num?)?.toInt() ?? 0,
          imageUrl: data['imageUrl'] as String?,
          userScore: (data['userScore'] as num?)?.toDouble(),
          reviewCount: (data['reviewCount'] as num?)?.toInt(),
        );
      }).toList();
      final payload = products
          .map(
            (e) => {
              'id': e.id,
              ...e.toFirestore(),
            },
          )
          .toList();
      _cache.saveIfChanged('favorites_$uid', payload).then((changed) {
        if (changed) {
          _cache.saveJsonWithTtl(
            key: 'favorites_$uid',
            value: payload,
            ttl: _cacheTtl,
          );
        }
      });
      return products;
    });
    return stream;
  }

  Future<List<Product>> readCachedFavorites(String uid) async {
    final list = await _cache.readFreshJsonList('favorites_$uid');
    if (list == null) return const [];
    return list.whereType<Map>().map((raw) {
      final data = Map<String, dynamic>.from(raw);
      return Product(
        id: (data['id'] as String?) ?? (data['name'] as String?) ?? 'cached',
        name: (data['name'] as String?) ?? '',
        price: ((data['price'] as num?) ?? 0).toDouble(),
        mainIngredients: List<String>.from(data['mainIngredients'] ?? const []),
        rating: ((data['rating'] as num?) ?? 1).clamp(1, 3).toInt(),
        affiliateUrl: (data['affiliateUrl'] as String?) ?? '',
        isFeatured: (data['isFeatured'] as bool?) ?? false,
        clickCount: (data['clickCount'] as num?)?.toInt() ?? 0,
        imageUrl: data['imageUrl'] as String?,
        userScore: (data['userScore'] as num?)?.toDouble(),
        reviewCount: (data['reviewCount'] as num?)?.toInt(),
      );
    }).toList();
  }

  Future<void> addFavorite({required String uid, required Product product}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(product.id)
        .set({
      'name': product.name,
      'price': product.price,
      'mainIngredients': product.mainIngredients,
      'rating': product.rating,
      'affiliateUrl': product.affiliateUrl,
      'isFeatured': product.isFeatured,
      'clickCount': product.clickCount,
      'imageUrl': product.imageUrl,
      'userScore': product.userScore,
      'reviewCount': product.reviewCount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFavorite({required String uid, required String productId}) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId)
        .delete();
  }
}
