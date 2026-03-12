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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: _parsePrice(json['price']),
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : null,
      categoryId: json['category_id'] as String?,
      featured: json['featured'] as bool? ?? false,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  final String? id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String>? images;
  final String? categoryId;
  final bool featured;

  String get displayImage =>
      imageUrl ?? (images != null && images!.isNotEmpty ? images!.first : '');
}
