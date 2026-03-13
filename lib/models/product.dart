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
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      images: json['images'] != null && json['images'] is List
          ? (json['images'] as List).map((e) => e?.toString() ?? '').toList()
          : null,
      categoryId: json['category_id']?.toString(),
      featured: json['featured'] == true ||
          json['featured'] == 1 ||
          ((json['featured']?.toString() ?? '').toLowerCase() == 'true'),
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

  String get displayImage =>
      imageUrl ?? (images != null && images!.isNotEmpty ? images!.first : '');
}
