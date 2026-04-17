class NewsEntity {
  final String? sourceName;
  final String? author;
  final String title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;

  const NewsEntity({
    this.sourceName,
    this.author,
    required this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });
}
