class Category {
  Category({
    this.id,
    this.name = '',
    this.slug,
    this.imageUrl,
    this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      imageUrl: json['image_url'] as String? ?? json['image'] as String?,
      productCount: json['product_count'] as int?,
    );
  }

  final String? id;
  final String name;
  final String? slug;
  final String? imageUrl;
  final int? productCount;
}
