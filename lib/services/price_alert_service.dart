import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class PriceAlertService {
  PriceAlertService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<bool> hasAlert({
    required String uid,
    required String productId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('priceAlerts')
        .doc(productId)
        .get();
    return doc.exists;
  }

  Future<void> upsertAlert({
    required String uid,
    required Product product,
    required double targetPrice,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('priceAlerts')
        .doc(product.id)
        .set({
      'productId': product.id,
      'productName': product.name,
      'currentPrice': product.price,
      'targetPrice': targetPrice,
      'affiliateUrl': product.affiliateUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeAlert({
    required String uid,
    required String productId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('priceAlerts')
        .doc(productId)
        .delete();
  }
}
