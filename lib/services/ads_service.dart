import 'package:cloud_firestore/cloud_firestore.dart';

class AdPoolConfig {
  const AdPoolConfig({
    required this.pool,
    required this.messages,
    required this.enabled,
    required this.priority,
    this.startAt,
    this.endAt,
  });

  final String pool;
  final List<String> messages;
  final bool enabled;
  final int priority;
  final DateTime? startAt;
  final DateTime? endAt;

  factory AdPoolConfig.fromDoc(String pool, Map<String, dynamic>? data) {
    final rawMessages = data?['messages'];
    final messages = rawMessages is List
        ? rawMessages
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList()
        : const <String>[];
    return AdPoolConfig(
      pool: pool,
      messages: messages,
      enabled: (data?['enabled'] as bool?) ?? true,
      priority: (data?['priority'] as num?)?.toInt() ?? 100,
      startAt: _toDateTime(data?['startAt']),
      endAt: _toDateTime(data?['endAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messages': messages,
      'enabled': enabled,
      'priority': priority,
      'startAt': startAt != null ? Timestamp.fromDate(startAt!) : null,
      'endAt': endAt != null ? Timestamp.fromDate(endAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool isActiveAt(DateTime now) {
    if (!enabled) return false;
    if (startAt != null && now.isBefore(startAt!)) return false;
    if (endAt != null && now.isAfter(endAt!)) return false;
    return true;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
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

  Future<void> saveDraftConfig(AdPoolConfig config) {
    return _firestore
        .collection('adConfigDrafts')
        .doc(config.pool)
        .set(config.toMap(), SetOptions(merge: true));
  }

  Future<AdPoolConfig> getDraftConfigOnce(String pool) async {
    final doc = await _firestore.collection('adConfigDrafts').doc(pool).get();
    return AdPoolConfig.fromDoc(pool, doc.data());
  }

  Future<void> publishPoolConfig(AdPoolConfig config) async {
    await _firestore.runTransaction((tx) async {
      final liveRef = _firestore.collection('adConfigs').doc(config.pool);
      final liveSnapshot = await tx.get(liveRef);
      final current = AdPoolConfig.fromDoc(config.pool, liveSnapshot.data());
      final historyRef = liveRef.collection('history').doc();
      tx.set(liveRef, config.toMap(), SetOptions(merge: true));
      tx.set(historyRef, {
        'messages': current.messages,
        'enabled': current.enabled,
        'priority': current.priority,
        'startAt': current.startAt != null
            ? Timestamp.fromDate(current.startAt!)
            : null,
        'endAt': current.endAt != null
            ? Timestamp.fromDate(current.endAt!)
            : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<List<AdPoolConfig>> getPoolHistory(
    String pool, {
    int limit = 10,
  }) async {
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

  Future<void> trackAdImpression({
    required String pool,
    required String message,
    required String userId,
  }) {
    return _trackAdEvent(
      pool: pool,
      message: message,
      userId: userId,
      type: 'impression',
    );
  }

  Future<void> trackAdClick({
    required String pool,
    required String message,
    required String userId,
  }) {
    return _trackAdEvent(
      pool: pool,
      message: message,
      userId: userId,
      type: 'click',
    );
  }

  Future<void> _trackAdEvent({
    required String pool,
    required String message,
    required String userId,
    required String type,
  }) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) return;
    final adId = _buildStableAdId(pool, normalizedMessage);

    await _firestore.collection('adEvents').add({
      'adId': adId,
      'pool': pool,
      'message': normalizedMessage,
      'type': type,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _buildStableAdId(String pool, String message) {
    final normalizedPool = pool.trim().toLowerCase();
    final normalizedMessage = message.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    return '${normalizedPool}_${_stableHash(normalizedMessage)}';
  }

  int _stableHash(String input) {
    var hash = 0xcbf29ce484222325;
    const prime = 0x100000001b3;
    const mask = 0x7fffffffffffffff;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * prime) & mask;
    }
    return hash;
  }
}
