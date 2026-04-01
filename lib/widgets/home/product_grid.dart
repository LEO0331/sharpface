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
        final imageHeight = crossAxisCount == 3 ? 108.0 : 122.0;
        final aspectRatio = crossAxisCount == 3 ? 0.82 : 0.72;

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
            return _ProductCard(
              product: product,
              isFav: isFav,
              imageHeight: imageHeight,
              review: reviewSamples[product.id]?.first,
              buyLabel: buyLabel,
              onOpenDetail: () => onOpenDetail(product),
              onToggleFavorite: () => onToggleFavorite(product),
              onBuy: () => onBuy(product),
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
        final aspectRatio = crossAxisCount == 3 ? 0.82 : 0.72;
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
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4E2FB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 108,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E4FA),
                borderRadius: BorderRadius.circular(13),
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

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.product,
    required this.isFav,
    required this.imageHeight,
    required this.buyLabel,
    required this.onOpenDetail,
    required this.onToggleFavorite,
    required this.onBuy,
    this.review,
  });

  final Product product;
  final bool isFav;
  final double imageHeight;
  final String buyLabel;
  final String? review;
  final VoidCallback onOpenDetail;
  final VoidCallback onToggleFavorite;
  final VoidCallback onBuy;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactMode = textScale > 1.2;
    final effectiveImageHeight = compactMode
        ? (widget.imageHeight - 18).clamp(84.0, 140.0).toDouble()
        : widget.imageHeight;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: _hovered ? const Offset(0, -0.02) : Offset.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onOpenDetail,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: product.isFeatured
                  ? const LinearGradient(
                      colors: [Color(0xFFFFF9C4), Color(0xFFFFF4B5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: product.isFeatured
                    ? const Color(0xFFE8D98A)
                    : const Color(0xFFE4E2FB),
              ),
              boxShadow: _hovered
                  ? const [
                      BoxShadow(
                        color: Color(0x298B97D9),
                        blurRadius: 22,
                        offset: Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Color(0x145A67A6),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0x1A8B97D9),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Color(0x0D5A67A6),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'product-image-${product.name}',
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: AnimatedScale(
                          scale: _hovered ? 1.04 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          child: product.imageUrl == null
                              ? Container(
                                  width: double.infinity,
                                  height: effectiveImageHeight,
                                  color: const Color(0xFFE8ECF8),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.inventory_2_outlined),
                                )
                              : Hero(
                                  tag: 'product-image-${product.id}',
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl!,
                                    width: double.infinity,
                                    height: effectiveImageHeight,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: effectiveImageHeight,
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      height: effectiveImageHeight,
                                      color: const Color(0xFFE2E8F0),
                                      alignment: Alignment.center,
                                      child: const Text('圖片載入中'),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      if (product.isFeatured)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFE3D58A)),
                            ),
                            child: const Text(
                              'SPONSORED',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 0.4,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E3A66),
                      ),
                ),
                Text(
                  '主成分：${product.mainIngredients.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
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
                if (!compactMode && product.userScore != null && product.reviewCount != null)
                  Text(
                    '評價 ${product.userScore}/5 (${product.reviewCount})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (!compactMode && widget.review != null)
                  Text(
                    '• ${widget.review}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const Spacer(),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: widget.onToggleFavorite,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        minimumSize: const Size(34, 32),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Icon(
                        widget.isFav ? Icons.favorite : Icons.favorite_border,
                        size: 17,
                        color: widget.isFav ? const Color(0xFFE15D88) : null,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: widget.onBuy,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE9EEFF),
                          foregroundColor: const Color(0xFF2F3E7A),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(widget.buyLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
