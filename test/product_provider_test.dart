import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sharpface/providers/product_provider.dart';
import 'package:sharpface/services/product_repository.dart';

void main() {
  test(
    'productProvider reorders featured products before trimming to 10',
    () async {
      final firestore = FakeFirebaseFirestore();
      for (var index = 0; index < 12; index++) {
        await firestore.collection('products').doc('p$index').set({
          'name': 'Product $index',
          'price': 100 + index,
          'mainIngredients': ['A'],
          'rating': 1,
          'affiliateUrl': 'https://example.com/$index',
          'isFeatured': index >= 10,
          'clickCount': 0,
        });
      }

      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            ProductRepository(firestore),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(productProvider.future);

      expect(result.length, 10);
      expect(result.first.id, 'p10');
      expect(result[1].id, 'p11');
      expect(result.where((product) => product.isFeatured).length, 2);
    },
  );
}
