class Testimonial {
  Testimonial({
    this.id,
    this.authorName = '',
    this.authorTitle,
    this.content = '',
    this.rating,
    this.avatarUrl,
  });

  static String _str(dynamic v) => v?.toString() ?? '';

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    final authorName = _str(json['author_name']).isEmpty ? _str(json['author']) : _str(json['author_name']);
    final content = _str(json['content']).isEmpty ? _str(json['text']) : _str(json['content']);
    final avatarUrl = _str(json['avatar_url']).isEmpty ? _str(json['avatar']) : _str(json['avatar_url']);
    return Testimonial(
      id: _str(json['id']).isEmpty ? null : _str(json['id']),
      authorName: authorName,
      authorTitle: _str(json['author_title']).isEmpty ? null : _str(json['author_title']),
      content: content,
      rating: int.tryParse(_str(json['rating'])),
      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
    );
  }

  final String? id;
  final String authorName;
  final String? authorTitle;
  final String content;
  final int? rating;
  final String? avatarUrl;
}
