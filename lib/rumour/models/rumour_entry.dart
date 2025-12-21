import 'dart:convert';

List<RumourEntry> rumourEntryListFromJson(String str) =>
    List<RumourEntry>.from(
      json.decode(str).map((x) => RumourEntry.fromJson(x)),
    );

String rumourEntryListToJson(List<RumourEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RumourEntry {
  final int id;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final String sourceUrl;
  final String coverImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorUsername;

  RumourEntry({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.content,
    required this.sourceUrl,
    required this.coverImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.authorUsername,
  });

  factory RumourEntry.fromJson(Map<String, dynamic> json) {
    return RumourEntry(
      id: json['id'] as int,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      sourceUrl: json['source_url'] ?? '',
      coverImageUrl: json['cover_image_url'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      authorUsername: json['author_username'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slug': slug,
        'summary': summary,
        'content': content,
        'source_url': sourceUrl,
        'cover_image_url': coverImageUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'author_username': authorUsername,
      };
}
