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
    return _firestore
        .collection('adConfigs')
        .doc(config.pool)
        .set(config.toMap(), SetOptions(merge: true));
  }
}
