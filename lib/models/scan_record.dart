import 'package:cloud_firestore/cloud_firestore.dart';

class ScanRecord {
  const ScanRecord({
    required this.id,
    required this.userId,
    required this.skinType,
    required this.suggestion,
    required this.concerns,
    required this.createdAt,
    this.contact,
  });

  final String id;
  final String userId;
  final String skinType;
  final String suggestion;
  final List<String> concerns;
  final DateTime createdAt;
  final String? contact;

  factory ScanRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ScanRecord(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      skinType: (data['skinType'] as String?) ?? '',
      suggestion: (data['suggestion'] as String?) ?? '',
      concerns: List<String>.from(data['concerns'] ?? const []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contact: data['contact'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'skinType': skinType,
      'suggestion': suggestion,
      'concerns': concerns,
      'contact': contact,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
