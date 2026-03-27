import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/models/product.dart';
import 'package:sharpface/widgets/home/product_grid.dart';

void main() {
  testWidgets('ProductGrid renders in two columns with large text scale', (tester) async {
    final products = List.generate(
      4,
      (i) => Product(
        id: 'p$i',
        name: 'Product $i',
        price: (100 + i).toDouble(),
        mainIngredients: const ['A', 'B'],
        rating: 2,
        affiliateUrl: 'https://example.com',
        isFeatured: i == 0,
        clickCount: 0,
      ),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 430,
                child: ProductGrid(
                  products: products,
                  isLoading: false,
                  favorites: const {},
                  reviewSamples: const {},
                  onToggleFavorite: (_) {},
                  onBuy: (_) {},
                  onOpenDetail: (_) {},
                  buyLabel: 'Buy',
                  noProductText: 'No products',
                ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Product 0'), findsOneWidget);
    expect(find.text('Buy'), findsNWidgets(4));
    expect(find.byType(GridView), findsOneWidget);
  });
}
