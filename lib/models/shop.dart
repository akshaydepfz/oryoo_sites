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
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      domain: json['domain']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  final String? id;
  final String? name;
  final String? domain;
  final String? createdAt;
  final String? updatedAt;
}
