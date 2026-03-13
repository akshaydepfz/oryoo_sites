import '../utils/json_utils.dart';

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
    final authorName = safeStr(json['author_name']).isEmpty ? safeStr(json['author']) : safeStr(json['author_name']);
    final content = safeStr(json['content']).isEmpty ? safeStr(json['text']) : safeStr(json['content']);
    final avatarUrl = safeStr(json['avatar_url']).isEmpty ? safeStr(json['avatar']) : safeStr(json['avatar_url']);
    return Testimonial(
      id: safeStrOrNull(json['id']),
      authorName: authorName,
      authorTitle: safeStrOrNull(json['author_title']),
      content: content,
      rating: int.tryParse(safeStr(json['rating'])),
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
