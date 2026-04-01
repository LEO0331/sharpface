import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.reviews,
    required this.similarProducts,
    required this.recentProducts,
    required this.onOpenProduct,
    required this.onBuy,
  });

  final Product product;
  final List<String> reviews;
  final List<Product> similarProducts;
  final List<Product> recentProducts;
  final ValueChanged<Product> onOpenProduct;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(product.name)),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: FilledButton.icon(
            onPressed: onBuy,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('前往購買'),
          ),
        ),
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _TrustChip(label: '官方導購連結'),
                        _TrustChip(label: '價格透明'),
                        _TrustChip(label: '可收藏追蹤'),
                      ],
                    ),
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
            if (similarProducts.isNotEmpty) ...[
              const SizedBox(height: 10),
              _MiniProductSection(
                title: '相似商品',
                products: similarProducts,
                onOpenProduct: onOpenProduct,
              ),
            ],
            if (recentProducts.isNotEmpty) ...[
              const SizedBox(height: 10),
              _MiniProductSection(
                title: '最近看過',
                products: recentProducts,
                onOpenProduct: onOpenProduct,
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8DDF6)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _MiniProductSection extends StatelessWidget {
  const _MiniProductSection({
    required this.title,
    required this.products,
    required this.onOpenProduct,
  });

  final String title;
  final List<Product> products;
  final ValueChanged<Product> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...products.take(4).map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => onOpenProduct(item),
                leading: item.imageUrl == null
                    ? const Icon(Icons.inventory_2_outlined)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('\$${item.price.toStringAsFixed(0)}'),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
