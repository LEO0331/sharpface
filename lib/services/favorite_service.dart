import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class FavoriteService {
  FavoriteService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Product>> watchFavorites(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
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
    });
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
