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
      id: json['id'] as String?,
      authorName: json['author_name'] as String? ?? json['author'] as String? ?? '',
      authorTitle: json['author_title'] as String?,
      content: json['content'] as String? ?? json['text'] as String? ?? '',
      rating: json['rating'] as int?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
    );
  }

  final String? id;
  final String authorName;
  final String? authorTitle;
  final String content;
  final int? rating;
  final String? avatarUrl;
}
