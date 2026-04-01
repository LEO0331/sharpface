import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/design_tokens.dart';
import '../models/product.dart';
import '../services/price_alert_service.dart';

class ProductDetailPage extends StatefulWidget {
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
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _priceAlertService = PriceAlertService();
  bool _alertEnabled = false;
  bool _loadingAlert = true;

  @override
  void initState() {
    super.initState();
    _loadAlertState();
  }

  Future<void> _loadAlertState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingAlert = false);
      return;
    }
    final enabled = await _priceAlertService.hasAlert(
      uid: user.uid,
      productId: widget.product.id,
    );
    if (!mounted) return;
    setState(() {
      _alertEnabled = enabled;
      _loadingAlert = false;
    });
  }

  Future<void> _togglePriceAlert() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先登入，才能使用降價通知。')),
      );
      return;
    }

    if (_alertEnabled) {
      await _priceAlertService.removeAlert(
        uid: user.uid,
        productId: widget.product.id,
      );
      if (!mounted) return;
      setState(() => _alertEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已取消降價通知。')),
      );
      return;
    }

    final defaultTarget = (widget.product.price * 0.9).toStringAsFixed(0);
    final controller = TextEditingController(text: defaultTarget);
    final price = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('設定降價通知'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '目標價格',
            hintText: '例如 699',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null || value <= 0) return;
              Navigator.pop(context, value);
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (price == null) return;

    await _priceAlertService.upsertAlert(
      uid: user.uid,
      product: widget.product,
      targetPrice: price,
    );
    if (!mounted) return;
    setState(() => _alertEnabled = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已設定降價通知（目標 \$${price.toStringAsFixed(0)}）。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.product.name)),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppTokens.space3,
            AppTokens.space2,
            AppTokens.space3,
            AppTokens.space3,
          ),
          child: FilledButton.icon(
            onPressed: widget.onBuy,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('前往購買'),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.product.imageUrl != null)
              Hero(
                tag: 'product-image-${widget.product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  child: CachedNetworkImage(
                    imageUrl: widget.product.imageUrl!,
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
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, size: 36),
              ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('價格：\$${widget.product.price.toStringAsFixed(0)}'),
                    Text('主成分：${widget.product.mainIngredients.join(', ')}'),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(
                        3,
                        (index) => Icon(
                          index < widget.product.rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFF6676DD),
                        ),
                      ),
                    ),
                    if (widget.product.userScore != null && widget.product.reviewCount != null)
                      Text(
                        '使用者評分：${widget.product.userScore}/5（${widget.product.reviewCount} 則）',
                      ),
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
                    const SizedBox(height: 10),
                    if (_loadingAlert)
                      const LinearProgressIndicator(minHeight: 2)
                    else
                      OutlinedButton.icon(
                        onPressed: _togglePriceAlert,
                        icon: Icon(
                          _alertEnabled
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_outlined,
                        ),
                        label: Text(_alertEnabled ? '已設定降價通知（點擊可取消）' : '設定降價通知'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('使用者評價', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (widget.reviews.isEmpty)
                      const Text('目前暫無評價。')
                    else
                      ...widget.reviews.map((review) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('• $review'),
                          )),
                  ],
                ),
              ),
            ),
            if (widget.similarProducts.isNotEmpty) ...[
              const SizedBox(height: 10),
              _MiniProductSection(
                title: '相似商品',
                products: widget.similarProducts,
                onOpenProduct: widget.onOpenProduct,
              ),
            ],
            if (widget.recentProducts.isNotEmpty) ...[
              const SizedBox(height: 10),
              _MiniProductSection(
                title: '最近看過',
                products: widget.recentProducts,
                onOpenProduct: widget.onOpenProduct,
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
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
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
        padding: const EdgeInsets.all(AppTokens.space3),
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
