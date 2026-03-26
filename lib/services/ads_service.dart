import 'package:cloud_firestore/cloud_firestore.dart';

class AdPoolConfig {
  const AdPoolConfig({
    required this.pool,
    required this.messages,
    required this.enabled,
    required this.priority,
  });

  final String pool;
  final List<String> messages;
  final bool enabled;
  final int priority;

  factory AdPoolConfig.fromDoc(String pool, Map<String, dynamic>? data) {
    final rawMessages = data?['messages'];
    final messages = rawMessages is List
        ? rawMessages.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList()
        : const <String>[];
    return AdPoolConfig(
      pool: pool,
      messages: messages,
      enabled: (data?['enabled'] as bool?) ?? true,
      priority: (data?['priority'] as num?)?.toInt() ?? 100,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messages': messages,
      'enabled': enabled,
      'priority': priority,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class AdsService {
  AdsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<AdPoolConfig> watchPoolConfig(String pool) {
    return _firestore.collection('adConfigs').doc(pool).snapshots().map((doc) {
      return AdPoolConfig.fromDoc(pool, doc.data());
    });
  }

  Future<AdPoolConfig> getPoolConfigOnce(String pool) async {
    final doc = await _firestore.collection('adConfigs').doc(pool).get();
    return AdPoolConfig.fromDoc(pool, doc.data());
  }

  Future<void> savePoolConfig(AdPoolConfig config) {
    return _firestore.collection('adConfigs').doc(config.pool).set(
          config.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> saveDraftConfig(AdPoolConfig config) {
    return _firestore.collection('adConfigDrafts').doc(config.pool).set(
          config.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<AdPoolConfig> getDraftConfigOnce(String pool) async {
    final doc = await _firestore.collection('adConfigDrafts').doc(pool).get();
    return AdPoolConfig.fromDoc(pool, doc.data());
  }

  Future<void> publishPoolConfig(AdPoolConfig config) async {
    final current = await getPoolConfigOnce(config.pool);
    await _firestore.runTransaction((tx) async {
      final liveRef = _firestore.collection('adConfigs').doc(config.pool);
      final historyRef = liveRef.collection('history').doc();
      tx.set(liveRef, config.toMap(), SetOptions(merge: true));
      tx.set(historyRef, {
        'messages': current.messages,
        'enabled': current.enabled,
        'priority': current.priority,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<List<AdPoolConfig>> getPoolHistory(String pool, {int limit = 10}) async {
    final snapshot = await _firestore
        .collection('adConfigs')
        .doc(pool)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => AdPoolConfig.fromDoc(pool, doc.data()))
        .toList();
  }
}
