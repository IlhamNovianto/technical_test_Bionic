import 'package:technical_test/domain/entities/news_entities.dart';

class NewsModel extends NewsEntity {
  const NewsModel({
    super.sourceName,
    super.author,
    required super.title,
    super.description,
    super.url,
    super.urlToImage,
    super.publishedAt,
    super.content,
  });

  // ── Dari JSON (API response) ───────────────────────────────
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      sourceName: json['source']?['name']?.toString(),
      author: json['author']?.toString(),
      title: json['title']?.toString() ?? 'Tanpa Judul',
      description: json['description']?.toString(),
      url: json['url']?.toString() ?? '',
      urlToImage: json['urlToImage']?.toString(),
      publishedAt: json['publishedAt']?.toString(),
      content: json['content']?.toString(),
    );
  }

  // ── Dari Entity (domain → data) ────────────────────────────
  factory NewsModel.fromEntity(NewsEntity entity) {
    return NewsModel(
      sourceName: entity.sourceName,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAt: entity.publishedAt,
      content: entity.content,
    );
  }

  // ── Dari SQLite Map ────────────────────────────────────────
  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      sourceName: map['sourceName'],
      author: map['author'],
      title: map['title'] ?? '',
      description: map['description'],
      url: map['url'] ?? '',
      urlToImage: map['urlToImage'],
      publishedAt: map['publishedAt'],
      content: map['content'],
    );
  }

  // ── Ke JSON ────────────────────────────────────────────────
  Map<String, dynamic> toJson() => {
    'sourceName': sourceName,
    'author': author,
    'title': title,
    'description': description,
    'url': url ?? '',
    'urlToImage': urlToImage,
    'publishedAt': publishedAt,
    'content': content,
  };

  // ── Ke SQLite Map ──────────────────────────────────────────
  Map<String, dynamic> toMap() => toJson();
}
