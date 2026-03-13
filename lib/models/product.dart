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

  static String _str(dynamic v) => v?.toString() ?? '';
  static double _double(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _str(json['id']).isEmpty ? null : _str(json['id']),
      name: _str(json['name']),
      description: _str(json['description']),
      price: _double(json['price']),
      imageUrl: () {
        final v = _str(json['image_url']).isEmpty ? _str(json['image']) : _str(json['image_url']);
        return v.isEmpty ? null : v;
      }(),
      images: json['images'] != null && json['images'] is List
          ? (json['images'] as List).map((e) => _str(e)).toList()
          : null,
      categoryId: _str(json['category_id']).isEmpty ? null : _str(json['category_id']),
      featured: json['featured'] == true ||
          json['featured'] == 1 ||
          (_str(json['featured']).toLowerCase() == 'true'),
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
