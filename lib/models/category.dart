class Category {
  Category({
    this.id,
    this.name = '',
    this.slug,
    this.imageUrl,
    this.productCount,
  });

  static String _str(dynamic v) => v?.toString() ?? '';

  factory Category.fromJson(Map<String, dynamic> json) {
    final imageUrl = _str(json['image_url']).isEmpty ? _str(json['image']) : _str(json['image_url']);
    return Category(
      id: _str(json['id']).isEmpty ? null : _str(json['id']),
      name: _str(json['name']),
      slug: _str(json['slug']).isEmpty ? null : _str(json['slug']),
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      productCount: int.tryParse(_str(json['product_count'])),
    );
  }

  final String? id;
  final String name;
  final String? slug;
  final String? imageUrl;
  final int? productCount;
}
