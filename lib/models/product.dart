import '../utils/json_utils.dart';

class ProductVariant {
  ProductVariant({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: safeStr(json['id']),
      name: safeStr(json['name']),
      price: safeDouble(json['price']),
    );
  }

  final String id;
  final String name;
  final double price;
}

class Product {
  Product({
    this.id,
    this.name = '',
    this.description = '',
    this.price = 0,
    this.imageUrl,
    this.images,
    this.categoryId,
    this.featured = false,
    this.variants = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageUrl =
        safeStr(json['image_url']).isEmpty ? safeStr(json['image']) : safeStr(json['image_url']);
    List<String>? images;
    if (json['images'] != null && json['images'] is List) {
      images = (json['images'] as List).map((e) => safeStr(e)).toList();
    }

    List<ProductVariant> variants = const [];
    if (json['variants'] != null && json['variants'] is List) {
      variants = (json['variants'] as List)
          .whereType<Map>()
          .map((e) => ProductVariant.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return Product(
      id: safeStrOrNull(json['id']),
      name: safeStr(json['name']),
      description: safeStr(json['description']),
      price: safeDouble(json['price']),
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      images: images,
      categoryId: safeStrOrNull(json['category_id']),
      featured: json['featured'] == true ||
          json['featured'] == 1 ||
          (safeStr(json['featured']).toLowerCase() == 'true'),
      variants: variants,
    );
  }

  final String? id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String>? images;
  final String? categoryId;
  final bool featured;
  final List<ProductVariant> variants;

  String get displayImage =>
      imageUrl ?? (images != null && images!.isNotEmpty ? images!.first : '');
}
