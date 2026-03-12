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
      id: json['id'] as String?,
      name: json['name'] as String?,
      domain: json['domain'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  final String? id;
  final String? name;
  final String? domain;
  final String? createdAt;
  final String? updatedAt;
}
