import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/services/scan_record_service.dart';

void main() {
  test('addScanRecord writes scan record data', () async {
    final firestore = FakeFirebaseFirestore();
    final service = ScanRecordService(firestore: firestore);

    await service.addScanRecord(
      userId: 'u1',
      skinType: '油性肌',
      suggestion: '晚間加強清潔',
      concerns: const ['痘痘'],
      contact: 'test@example.com',
    );

    final snapshot = await firestore.collection('scanRecords').get();
    expect(snapshot.docs.length, 1);

    final data = snapshot.docs.first.data();
    expect(data['userId'], 'u1');
    expect(data['skinType'], '油性肌');
    expect(data['suggestion'], '晚間加強清潔');
    expect(data['concerns'], ['痘痘']);
    expect(data['contact'], 'test@example.com');
    expect(data['createdAt'], isNotNull);
  });

  test('watchUserRecords filters by user and sorts by createdAt', () async {
    final firestore = FakeFirebaseFirestore();
    final service = ScanRecordService(firestore: firestore);

    final col = firestore.collection('scanRecords');
    await col.add({
      'userId': 'u1',
      'skinType': '乾性肌',
      'suggestion': '保濕',
      'concerns': ['乾燥'],
      'createdAt': Timestamp.fromDate(DateTime(2026, 3, 25)),
    });
    await col.add({
      'userId': 'u2',
      'skinType': '混合肌',
      'suggestion': '防曬',
      'concerns': ['出油'],
      'createdAt': Timestamp.fromDate(DateTime(2026, 3, 24)),
    });
    await col.add({
      'userId': 'u1',
      'skinType': '油性肌',
      'suggestion': '控油',
      'concerns': ['痘痘'],
      'createdAt': Timestamp.fromDate(DateTime(2026, 3, 23)),
    });

    final result = await service.watchUserRecords('u1').first;
    expect(result.length, 2);
    expect(result.first.skinType, '油性肌');
    expect(result.last.skinType, '乾性肌');
  });
}
