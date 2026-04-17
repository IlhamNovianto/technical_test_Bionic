import 'package:technical_test/domain/entities/news_entities.dart';

abstract class NewsRepository {
  Future<List<NewsEntity>> getLatestNews({int page = 1});
  Future<List<NewsEntity>> getNewsByCategory(String category, {int page = 1});
  Future<List<NewsEntity>> searchNews(String keyword, {int page = 1});
  Future<List<NewsEntity>> getBookmarks();
  Future<void> addBookmark(NewsEntity news);
  Future<void> removeBookmark(String url);
  Future<bool> isBookmarked(String url);
}
