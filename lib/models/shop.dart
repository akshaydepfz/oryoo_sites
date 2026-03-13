class Shop {
  Shop({
    this.id,
    this.name,
    this.domain,
    this.createdAt,
    this.updatedAt,
  });

  static String _str(dynamic v) => v?.toString() ?? '';

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: _str(json['id']).isEmpty ? null : _str(json['id']),
      name: _str(json['name']).isEmpty ? null : _str(json['name']),
      domain: _str(json['domain']).isEmpty ? null : _str(json['domain']),
      createdAt: _str(json['created_at']).isEmpty ? null : _str(json['created_at']),
      updatedAt: _str(json['updated_at']).isEmpty ? null : _str(json['updated_at']),
    );
  }

  final String? id;
  final String? name;
  final String? domain;
  final String? createdAt;
  final String? updatedAt;
}
