import 'package:cloud_firestore/cloud_firestore.dart';

class AdsService {
  AdsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<String>> watchPool(String pool) {
    return _firestore.collection('adConfigs').doc(pool).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return const <String>[];
      final raw = data['messages'];
      if (raw is! List) return const <String>[];
      return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    });
  }

  Future<List<String>> getPoolOnce(String pool) async {
    final doc = await _firestore.collection('adConfigs').doc(pool).get();
    final data = doc.data();
    if (data == null) return const <String>[];
    final raw = data['messages'];
    if (raw is! List) return const <String>[];
    return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
  }

  Future<void> savePool({
    required String pool,
    required List<String> messages,
  }) {
    return _firestore.collection('adConfigs').doc(pool).set({
      'messages': messages,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
