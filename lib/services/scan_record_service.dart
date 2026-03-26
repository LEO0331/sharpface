import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/scan_record.dart';

class ScanRecordService {
  ScanRecordService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> addScanRecord({
    required String userId,
    required String skinType,
    required String suggestion,
    required List<String> concerns,
    String? contact,
  }) async {
    await _firestore.collection('scanRecords').add({
      'userId': userId,
      'skinType': skinType,
      'suggestion': suggestion,
      'concerns': concerns,
      'contact': contact,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ScanRecord>> watchUserRecords(String userId) {
    return _firestore
        .collection('scanRecords')
        .where('userId', isEqualTo: userId)
        .limit(30)
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs.map(ScanRecord.fromFirestore).toList();
          records.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return records;
        });
  }
}
