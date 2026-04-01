import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
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
    if (isLoading) return const _ProductGridSkeleton();
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Text(noProductText),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 720 ? 3 : 2;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final isLargeText = textScale > 1.2;
        final imageHeight = crossAxisCount == 3 ? 96.0 : 90.0;
        final aspectRatio = isLargeText
            ? (crossAxisCount == 3 ? 0.70 : 0.56)
            : (crossAxisCount == 3 ? 0.82 : 0.66);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppTokens.space3,
            mainAxisSpacing: AppTokens.space3,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final product = items[index];
            return _ProductCard(
              product: product,
              isFav: favorites.contains(product.id),
              imageHeight: imageHeight,
              reviews: reviewSamples[product.id] ?? const [],
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
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final isLargeText = textScale > 1.2;
        final aspectRatio = isLargeText
            ? (crossAxisCount == 3 ? 0.70 : 0.56)
            : (crossAxisCount == 3 ? 0.82 : 0.66);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: crossAxisCount * 2,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppTokens.space3,
            mainAxisSpacing: AppTokens.space3,
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
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: AppTokens.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E4FA),
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
            const SizedBox(height: AppTokens.space2),
            Container(height: 12, width: double.infinity, color: const Color(0xFFDADFF9)),
            const SizedBox(height: 6),
            Container(height: 12, width: 80, color: const Color(0xFFDADFF9)),
            const Spacer(),
            Row(
              children: [
                Container(height: 34, width: 34, color: const Color(0xFFDADFF9)),
                const SizedBox(width: 6),
                Expanded(child: Container(height: 34, color: const Color(0xFFDADFF9))),
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
    this.reviews = const [],
  });

  final Product product;
  final bool isFav;
  final double imageHeight;
  final String buyLabel;
  final List<String> reviews;
  final VoidCallback onOpenDetail;
  final VoidCallback onToggleFavorite;
  final VoidCallback onBuy;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  String? _staticBadgeLabel(String productId) {
    switch (productId) {
      case 'static-1':
        return '人氣精選';
      case 'static-2':
        return '新手入門';
      case 'static-3':
        return '日常必備';
      case 'static-4':
        return '敏感友善';
      case 'static-5':
        return '熱銷推薦';
      case 'static-6':
        return '夜間修護';
      default:
        return null;
    }
  }

  String _effectLabel(Product product) {
    final ingredients = product.mainIngredients.join(',');
    if (ingredients.contains('水楊酸') || ingredients.contains('杜鵑花酸')) return '抗痘控油';
    if (ingredients.contains('玻尿酸') || ingredients.contains('神經醯胺')) return '補水修護';
    if (ingredients.contains('氧化鋅')) return '防曬防護';
    if (ingredients.contains('咖啡因')) return '眼周提亮';
    if (product.rating >= 3) return '高評價';
    return '日常保養';
  }

  List<String> _reviewLines(Product product) {
    final source = widget.reviews
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .take(3)
        .toList();
    if (source.length == 3) return source;

    final score = product.userScore ?? 4.2;
    final fallback = <String>[
      if (score >= 4.6) '吸收快、連續使用有感改善。',
      if (score >= 4.3) '質地清爽不厚重，日常好搭配。',
      '刺激感低，敏感時期也能穩定使用。',
      '價格與效果平衡，整體 CP 值不錯。',
      '香味與觸感自然，持續使用意願高。',
    ];

    final merged = [...source];
    for (final line in fallback) {
      if (merged.length >= 3) break;
      if (!merged.contains(line)) merged.add(line);
    }
    return merged.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isStaticProduct = product.id.startsWith('static-');
    final staticBadge = isStaticProduct ? _staticBadgeLabel(product.id) : null;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compactMode = textScale > 1.2;
    final effectiveImageHeight = compactMode
        ? (widget.imageHeight - 18).clamp(84.0, 140.0).toDouble()
        : widget.imageHeight;
    final imageHeightForCard = isStaticProduct
        ? ((compactMode ? effectiveImageHeight : effectiveImageHeight + 10)
            .clamp(84.0, 150.0)
            .toDouble())
        : effectiveImageHeight;
    final reviewLines = _reviewLines(product);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: _hovered ? const Offset(0, -0.02) : Offset.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
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
              borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              border: Border.all(
                color: product.isFeatured ? const Color(0xFFE8D98A) : AppTokens.borderSoft,
              ),
              boxShadow: _hovered ? AppTokens.shadowCardHover : AppTokens.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'product-image-${product.name}',
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        child: AnimatedScale(
                          scale: _hovered ? 1.04 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          child: product.imageUrl == null
                              ? Container(
                                  width: double.infinity,
                                  height: imageHeightForCard,
                                  color: const Color(0xFFE8ECF8),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.inventory_2_outlined),
                                )
                              : Hero(
                                  tag: 'product-image-${product.id}',
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl!,
                                    width: double.infinity,
                                    height: imageHeightForCard,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: imageHeightForCard,
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      height: imageHeightForCard,
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
                              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
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
                      if (staticBadge != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F3E7A).withValues(alpha: 0.86),
                              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                              border: Border.all(color: const Color(0xFFBFC9F7)),
                            ),
                            child: Text(
                              staticBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space2),
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
                if (!compactMode)
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
                ...reviewLines.map(
                  (line) => Text(
                    '• $line',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: compactMode ? 10.5 : null,
                        ),
                  ),
                ),
                SizedBox(height: compactMode ? 2 : 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compactMode ? 6 : 8,
                      vertical: compactMode ? 2 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3FF),
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                      border: Border.all(color: const Color(0xFFD8E1FF)),
                    ),
                    child: Text(
                      '效果：${_effectLabel(product)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3D4A84),
                            fontSize: compactMode ? 11 : null,
                          ),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _LuxuryIconButton(
                      hovered: _hovered,
                      active: widget.isFav,
                      onPressed: widget.onToggleFavorite,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _LuxuryBuyButton(
                        label: widget.buyLabel,
                        hovered: _hovered,
                        onPressed: widget.onBuy,
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

class _LuxuryIconButton extends StatelessWidget {
  const _LuxuryIconButton({
    required this.hovered,
    required this.active,
    required this.onPressed,
  });

  final bool hovered;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      width: 34,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          gradient: hovered
              ? const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFEFF3FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF7F9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(color: const Color(0xFFD9E0F8)),
        ),
        child: IconButton(
          onPressed: onPressed,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          icon: Icon(
            active ? Icons.favorite : Icons.favorite_border,
            size: 17,
            color: active ? const Color(0xFFE15D88) : const Color(0xFF5162A6),
          ),
        ),
      ),
    );
  }
}

class _LuxuryBuyButton extends StatefulWidget {
  const _LuxuryBuyButton({
    required this.label,
    required this.hovered,
    required this.onPressed,
  });

  final String label;
  final bool hovered;
  final VoidCallback onPressed;

  @override
  State<_LuxuryBuyButton> createState() => _LuxuryBuyButtonState();
}

class _LuxuryBuyButtonState extends State<_LuxuryBuyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant _LuxuryBuyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hovered && !oldWidget.hovered) {
      _shineController
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        gradient: widget.hovered
            ? const LinearGradient(
                colors: [Color(0xFFE3EAFF), Color(0xFFD2DEFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFE9EEFF), Color(0xFFDDE6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(color: const Color(0xFFC9D6FF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: Stack(
          fit: StackFit.expand,
          children: [
            TextButton(
              onPressed: widget.onPressed,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2F3E7A),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
              child: Text(widget.label),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _shineController,
                builder: (context, child) {
                  final t = _shineController.value;
                  final x = -1.2 + (2.4 * t);
                  return FractionalTranslation(
                    translation: Offset(x, 0),
                    child: Transform.rotate(
                      angle: 0.25,
                      child: Container(
                        width: 20,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0x00FFFFFF),
                              Color(0x80FFFFFF),
                              Color(0x00FFFFFF),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
