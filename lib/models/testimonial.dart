class Testimonial {
  Testimonial({
    this.id,
    this.authorName = '',
    this.authorTitle,
    this.content = '',
    this.rating,
    this.avatarUrl,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id']?.toString(),
      authorName: json['author_name']?.toString() ?? json['author']?.toString() ?? '',
      authorTitle: json['author_title']?.toString(),
      content: json['content']?.toString() ?? json['text']?.toString() ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '0'),
      avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString(),
    );
  }

  final String? id;
  final String authorName;
  final String? authorTitle;
  final String content;
  final int? rating;
  final String? avatarUrl;
}
