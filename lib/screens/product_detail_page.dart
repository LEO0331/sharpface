import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.reviews,
    required this.onBuy,
  });

  final Product product;
  final List<String> reviews;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(product.name)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (product.imageUrl != null)
              Hero(
                tag: 'product-image-${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, size: 36),
              ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('價格：\$${product.price.toStringAsFixed(0)}'),
                    Text('主成分：${product.mainIngredients.join(', ')}'),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(
                        3,
                        (index) => Icon(
                          index < product.rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFF6676DD),
                        ),
                      ),
                    ),
                    if (product.userScore != null && product.reviewCount != null)
                      Text('使用者評分：${product.userScore}/5（${product.reviewCount} 則）'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('使用者評價', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (reviews.isEmpty)
                      const Text('目前暫無評價。')
                    else
                      ...reviews.map((review) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $review'),
                          )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onBuy,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('前往購買'),
            ),
          ],
        ),
      ),
    );
  }
}
