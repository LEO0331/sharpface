import 'package:flutter/material.dart';

import '../../models/product.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.favorites,
    required this.reviewSamples,
    required this.onToggleFavorite,
    required this.onBuy,
  });

  final List<Product> products;
  final Set<String> favorites;
  final Map<String, List<String>> reviewSamples;
  final ValueChanged<Product> onToggleFavorite;
  final ValueChanged<Product> onBuy;

  @override
  Widget build(BuildContext context) {
    final items = products.take(10).toList();
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('查無符合條件的產品。'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.54,
      ),
      itemBuilder: (context, index) {
        final product = items[index];
        final isFav = favorites.contains(product.id);
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: product.isFeatured ? const Color(0xFFFFF9C4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product.imageUrl!,
                    width: double.infinity,
                    height: 92,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 92,
                      color: const Color(0xFFE2E8F0),
                      alignment: Alignment.center,
                      child: const Text('圖片載入中'),
                    ),
                  ),
                ),
              if (product.imageUrl != null) const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text('價格：\$${product.price.toStringAsFixed(0)}'),
              Text(
                '主成分：${product.mainIngredients.join(', ')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text('推薦星級：${product.rating}/3'),
              if (product.userScore != null && product.reviewCount != null)
                Text('評價：${product.userScore}/5 (${product.reviewCount})'),
              if (reviewSamples[product.id] != null)
                Text(
                  '• ${reviewSamples[product.id]!.first}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    onPressed: () => onToggleFavorite(product),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => onBuy(product),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: const Text('購買'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
