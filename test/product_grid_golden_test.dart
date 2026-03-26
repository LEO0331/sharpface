import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/models/product.dart';
import 'package:sharpface/widgets/home/product_grid.dart';

void main() {
  testWidgets('ProductGrid two-column golden', (tester) async {
    final products = List.generate(
      4,
      (i) => Product(
        id: 'g$i',
        name: 'Golden Product $i',
        price: (200 + i).toDouble(),
        mainIngredients: const ['Niacinamide', 'B5'],
        rating: 3,
        affiliateUrl: 'https://example.com',
        isFeatured: i == 0,
        clickCount: 0,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 430,
            child: ProductGrid(
              products: products,
              favorites: const {'g0'},
              reviewSamples: const {
                'g0': ['Good result'],
              },
              onToggleFavorite: (_) {},
              onBuy: (_) {},
              buyLabel: 'Buy',
              noProductText: 'No products',
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byType(ProductGrid),
      matchesGoldenFile('goldens/product_grid_two_column.png'),
    );
  });
}
