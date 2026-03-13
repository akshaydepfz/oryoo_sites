import '../utils/json_utils.dart';

class Category {
  Category({
    this.id,
    this.name = '',
    this.slug,
    this.imageUrl,
    this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final imageUrl = safeStr(json['image_url']).isEmpty ? safeStr(json['image']) : safeStr(json['image_url']);
    return Category(
      id: safeStrOrNull(json['id']),
      name: safeStr(json['name']),
      slug: safeStrOrNull(json['slug']),
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      productCount: int.tryParse(safeStr(json['product_count'])),
    );
  }

  final String? id;
  final String name;
  final String? slug;
  final String? imageUrl;
  final int? productCount;
}
