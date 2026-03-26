import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/models/app_user.dart';
import 'package:sharpface/models/product.dart';
import 'package:sharpface/models/scan_record.dart';

void main() {
  test('AppUser isAdmin and toFirestore work', () {
    final user = AppUser(
      id: 'u1',
      email: 'a@b.com',
      role: 'admin',
      createdAt: DateTime(2026, 3, 26),
      phoneNumber: '+886900000000',
    );

    expect(user.isAdmin, true);
    final map = user.toFirestore();
    expect(map['email'], 'a@b.com');
    expect(map['role'], 'admin');
    expect(map['phoneNumber'], '+886900000000');
    expect(map['createdAt'], isNotNull);
  });

  test('Product toFirestore keeps sponsor and rating values', () {
    const product = Product(
      id: 'p1',
      name: 'A',
      price: 599,
      mainIngredients: ['Niacinamide'],
      rating: 3,
      affiliateUrl: 'https://example.com',
      isFeatured: true,
      clickCount: 22,
    );

    final map = product.toFirestore();
    expect(map['name'], 'A');
    expect(map['price'], 599);
    expect(map['isFeatured'], true);
    expect(map['rating'], 3);
    expect(map['clickCount'], 22);
  });

  test('ScanRecord toFirestore includes concerns', () {
    final record = ScanRecord(
      id: 's1',
      userId: 'u1',
      skinType: '混合肌',
      suggestion: '保濕',
      concerns: const ['黑眼圈'],
      createdAt: DateTime(2026, 3, 26),
      contact: 'u1@example.com',
    );

    final map = record.toFirestore();
    expect(map['userId'], 'u1');
    expect(map['concerns'], ['黑眼圈']);
    expect(map['contact'], 'u1@example.com');
    expect(map['createdAt'], isNotNull);
  });
}
