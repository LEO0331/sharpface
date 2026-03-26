import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.mainIngredients,
    required this.rating,
    required this.affiliateUrl,
    required this.isFeatured,
    required this.clickCount,
  });

  final String id;
  final String name;
  final double price;
  final List<String> mainIngredients;
  final int rating;
  final String affiliateUrl;
  final bool isFeatured;
  final int clickCount;

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Product(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      price: ((data['price'] as num?) ?? 0).toDouble(),
      mainIngredients: List<String>.from(data['mainIngredients'] ?? const []),
      rating: ((data['rating'] as num?) ?? 1).clamp(1, 3).toInt(),
      affiliateUrl: (data['affiliateUrl'] as String?) ?? '',
      isFeatured: (data['isFeatured'] as bool?) ?? false,
      clickCount: (data['clickCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'mainIngredients': mainIngredients,
      'rating': rating,
      'affiliateUrl': affiliateUrl,
      'isFeatured': isFeatured,
      'clickCount': clickCount,
    };
  }
}
