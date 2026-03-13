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
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      productCount: int.tryParse(json['product_count']?.toString() ?? '0'),
    );
  }

  final String? id;
  final String name;
  final String? slug;
  final String? imageUrl;
  final int? productCount;
}
