import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductRepository {
  ProductRepository(this._firestore);

  final FirebaseFirestore _firestore;
  static const int _defaultCandidateMultiplier = 3;

  Future<List<Product>> fetchProducts({int limit = 10}) async {
    final fetchLimit = limit <= 0 ? 10 : limit * _defaultCandidateMultiplier;
    final snapshot = await _firestore
        .collection('products')
        .limit(fetchLimit)
        .get();

    return snapshot.docs.map(Product.fromFirestore).toList();
  }

  Future<void> increaseClickCount(String productId) async {
    await _firestore.collection('products').doc(productId).update({
      'clickCount': FieldValue.increment(1),
    });
  }
}
