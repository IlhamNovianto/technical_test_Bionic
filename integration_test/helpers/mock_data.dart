import 'package:technical_test/domain/entities/news_entities.dart';

class MockData {
  // News data
  static const newsEntity = NewsEntity(
    sourceName: 'BBC News',
    author: 'Test Author',
    title: 'Flutter 4.0 Released with Major Updates',
    description: 'Flutter team announced major updates today.',
    url: 'https://example.com/news/flutter-4',
    urlToImage: 'https://picsum.photos/400/200',
    publishedAt: '2024-11-01T10:00:00Z',
    content: 'Full content of the article goes here...',
  );

  static const newsEntityNoUrl = NewsEntity(
    sourceName: 'Test Source',
    title: 'Article Without URL',
    description: 'This article has no URL.',
    url: null,
    publishedAt: '2024-11-01T10:00:00Z',
  );

  static const List<NewsEntity> newsList = [
    newsEntity,
    NewsEntity(
      sourceName: 'TechCrunch',
      author: 'Jane Doe',
      title: 'Dart 4.0 Brings New Features',
      description: 'Dart language gets exciting new features.',
      url: 'https://example.com/news/dart-4',
      publishedAt: '2024-11-02T08:00:00Z',
    ),
  ];

  // Chat data
  static const chatMessage = 'Halo, ada berita apa hari ini?';
  static const botReply = 'Halo! Cek halaman News untuk berita terkini 📰';
  static const searchKeyword = 'flutter';
}
