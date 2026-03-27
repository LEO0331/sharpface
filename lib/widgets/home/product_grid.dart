import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/product.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.isLoading,
    required this.favorites,
    required this.reviewSamples,
    required this.onToggleFavorite,
    required this.onBuy,
    required this.onOpenDetail,
    required this.buyLabel,
    required this.noProductText,
  });

  final List<Product> products;
  final bool isLoading;
  final Set<String> favorites;
  final Map<String, List<String>> reviewSamples;
  final ValueChanged<Product> onToggleFavorite;
  final ValueChanged<Product> onBuy;
  final ValueChanged<Product> onOpenDetail;
  final String buyLabel;
  final String noProductText;

  @override
  Widget build(BuildContext context) {
    final items = products.take(10).toList();
    if (isLoading) {
      return const _ProductGridSkeleton();
    }
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(noProductText),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 720 ? 3 : 2;
        final imageHeight = crossAxisCount == 3 ? 80.0 : 92.0;
        final aspectRatio = crossAxisCount == 3 ? 0.63 : 0.55;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final product = items[index];
            final isFav = favorites.contains(product.id);
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onOpenDetail(product),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: product.isFeatured ? const Color(0xFFFFF9C4) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E2FB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x147A80E8),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.imageUrl != null)
                      Semantics(
                        label: 'product-image-${product.name}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Hero(
                            tag: 'product-image-${product.id}',
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrl!,
                              width: double.infinity,
                              height: imageHeight,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: imageHeight,
                                color: const Color(0xFFE2E8F0),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: imageHeight,
                                color: const Color(0xFFE2E8F0),
                                alignment: Alignment.center,
                                child: const Text('圖片載入中'),
                              ),
                            ),
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
                    Row(
                      children: List.generate(
                        3,
                        (star) => Icon(
                          star < product.rating ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 15,
                          color: const Color(0xFF6676DD),
                        ),
                      ),
                    ),
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
                        FilledButton.tonal(
                          onPressed: () => onToggleFavorite(product),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(36, 34),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFav ? const Color(0xFFE15D88) : null,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => onBuy(product),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              minimumSize: const Size(0, 34),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(buyLabel),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductGridSkeleton extends StatelessWidget {
  const _ProductGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 720 ? 3 : 2;
        final aspectRatio = crossAxisCount == 3 ? 0.63 : 0.55;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: crossAxisCount * 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) => const _SkeletonCard(),
        );
      },
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.48, end: 0.95).animate(_controller),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E2FB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E4FA),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 12, width: double.infinity, color: const Color(0xFFDADFF9)),
            const SizedBox(height: 6),
            Container(height: 12, width: 80, color: const Color(0xFFDADFF9)),
            const Spacer(),
            Row(
              children: [
                Container(height: 34, width: 34, color: const Color(0xFFDADFF9)),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(height: 34, color: const Color(0xFFDADFF9)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
