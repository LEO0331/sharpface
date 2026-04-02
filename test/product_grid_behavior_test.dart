import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sharpface/models/product.dart';
import 'package:sharpface/widgets/home/product_grid.dart';

void main() {
  const product = Product(
    id: 'p1',
    name: 'Test Product',
    price: 300,
    mainIngredients: ['Niacinamide', 'B5'],
    rating: 3,
    affiliateUrl: 'https://example.com',
    isFeatured: true,
    clickCount: 0,
  );

  testWidgets('shows skeleton grid when loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            child: ProductGrid(
              products: const [product],
              isLoading: true,
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
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('No products'), findsNothing);
    expect(find.text('Test Product'), findsNothing);
  });

  testWidgets('card/buttons call callbacks', (tester) async {
    Product? opened;
    Product? toggled;
    Product? bought;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            child: ProductGrid(
              products: const [product],
              isLoading: false,
              favorites: const {},
              reviewSamples: const {},
              onToggleFavorite: (p) => toggled = p,
              onBuy: (p) => bought = p,
              onOpenDetail: (p) => opened = p,
              buyLabel: 'Buy',
              noProductText: 'No products',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Product'));
    await tester.pumpAndSettle();
    expect(opened?.id, 'p1');

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(toggled?.id, 'p1');

    await tester.tap(find.text('Buy'));
    await tester.pumpAndSettle();
    expect(bought?.id, 'p1');
  });

  testWidgets('shows 3 review lines per card with fallback text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            child: ProductGrid(
              products: const [product],
              isLoading: false,
              favorites: const {},
              reviewSamples: const {
                'p1': ['清爽不黏膩'],
              },
              onToggleFavorite: (_) {},
              onBuy: (_) {},
              onOpenDetail: (_) {},
              buyLabel: 'Buy',
              noProductText: 'No products',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((widget) {
        return widget is Text &&
            widget.data != null &&
            widget.data!.startsWith('• ');
      }),
      findsNWidgets(3),
    );
  });

  testWidgets('renders featured badge and effect chip text', (
    tester,
  ) async {
    const featuredProduct = Product(
      id: 'p2',
      name: 'Featured Item',
      price: 350,
      mainIngredients: ['水楊酸'],
      rating: 2,
      affiliateUrl: 'https://example.com/s1',
      isFeatured: true,
      clickCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            child: ProductGrid(
              products: const [featuredProduct],
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
    );
    await tester.pumpAndSettle();

    expect(find.text('SPONSORED'), findsOneWidget);
    expect(find.textContaining('效果：抗痘控油'), findsOneWidget);
  });

  testWidgets('shows no-product text when item list is empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            child: ProductGrid(
              products: const [],
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
    );

    expect(find.text('No products'), findsOneWidget);
  });
}
