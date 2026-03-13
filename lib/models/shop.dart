import '../utils/json_utils.dart';

class Shop {
  Shop({
    this.id,
    this.name,
    this.domain,
    this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: safeStrOrNull(json['id']),
      name: safeStrOrNull(json['name']),
      domain: safeStrOrNull(json['domain']),
      createdAt: safeStrOrNull(json['created_at']),
      updatedAt: safeStrOrNull(json['updated_at']),
    );
  }

  final String? id;
  final String? name;
  final String? domain;
  final String? createdAt;
  final String? updatedAt;
}
