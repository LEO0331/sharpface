import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalUsers,
    required this.todayScans,
    required this.topProductName,
  });

  final int totalUsers;
  final int todayScans;
  final String topProductName;
}

class AdminService {
  AdminService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<AdminDashboardStats> fetchStats() async {
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

    return AdminDashboardStats(
      totalUsers: userSnapshot.count ?? 0,
      todayScans: todayScansSnapshot.count ?? 0,
      topProductName: topName,
    );
  }
}
