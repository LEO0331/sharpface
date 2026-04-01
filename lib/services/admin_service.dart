import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalUsers,
    required this.todayScans,
    required this.topProductName,
    required this.topAdMessage,
    required this.topAdCtr,
  });

  final int totalUsers;
  final int todayScans;
  final String topProductName;
  final String topAdMessage;
  final double topAdCtr;
}

class AdminPermissionException implements Exception {
  const AdminPermissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AdminService {
  AdminService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<AdminDashboardStats> fetchStats() async {
    try {
      final userSnapshot = await _firestore.collection('users').count().get();

      final start = DateTime.now();
      final todayStart = DateTime(start.year, start.month, start.day);
      final todayScansSnapshot = await _firestore
          .collection('scanRecords')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .count()
          .get();

      final topProductSnapshot = await _firestore
          .collection('products')
          .orderBy('clickCount', descending: true)
          .limit(1)
          .get();

      final topName = topProductSnapshot.docs.isEmpty
          ? 'No data'
          : (topProductSnapshot.docs.first.data()['name'] as String? ?? 'No data');

      final topAd = await _computeTopAdFromEvents();

      return AdminDashboardStats(
        totalUsers: userSnapshot.count ?? 0,
        todayScans: todayScansSnapshot.count ?? 0,
        topProductName: topName,
        topAdMessage: topAd.$1,
        topAdCtr: topAd.$2,
      );
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;

      final fallback = await _readFromSummaryDoc();
      if (fallback != null) return fallback;

      throw const AdminPermissionException(
        '沒有管理後台讀取權限。請在 Firestore Rules 允許 admin 讀取 users/scanRecords/products 或 adminStats/summary。',
      );
    }
  }

  Future<AdminDashboardStats?> _readFromSummaryDoc() async {
    try {
      final doc = await _firestore.collection('adminStats').doc('summary').get();
      if (!doc.exists) return null;
      final data = doc.data() ?? <String, dynamic>{};
      return AdminDashboardStats(
        totalUsers: (data['totalUsers'] as num?)?.toInt() ?? 0,
        todayScans: (data['todayScans'] as num?)?.toInt() ?? 0,
        topProductName: (data['topProductName'] as String?) ?? 'No data',
        topAdMessage: (data['topAdMessage'] as String?) ?? 'No data',
        topAdCtr: (data['topAdCtr'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<(String, double)> _computeTopAdFromEvents() async {
    final snapshot = await _firestore
        .collection('adEvents')
        .orderBy('createdAt', descending: true)
        .limit(1000)
        .get();
    if (snapshot.docs.isEmpty) return ('No data', 0.0);

    final impressions = <String, int>{};
    final clicks = <String, int>{};
    final labels = <String, String>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final adId = (data['adId'] as String?) ?? '';
      final message = (data['message'] as String?) ?? 'No data';
      final type = (data['type'] as String?) ?? '';
      if (adId.isEmpty) continue;
      labels[adId] = message;
      if (type == 'impression') {
        impressions[adId] = (impressions[adId] ?? 0) + 1;
      } else if (type == 'click') {
        clicks[adId] = (clicks[adId] ?? 0) + 1;
      }
    }

    String topAdId = '';
    double topCtr = 0;
    int topImpressions = 0;
    for (final entry in impressions.entries) {
      final adId = entry.key;
      final imp = entry.value;
      if (imp <= 0) continue;
      final clk = clicks[adId] ?? 0;
      final ctr = clk / imp;
      if (ctr > topCtr || (ctr == topCtr && imp > topImpressions)) {
        topCtr = ctr;
        topImpressions = imp;
        topAdId = adId;
      }
    }

    if (topAdId.isEmpty) return ('No data', 0.0);
    return (labels[topAdId] ?? 'No data', topCtr);
  }
}
