import 'package:technical_test/data/database/dao/news_dao.dart';
import 'package:technical_test/data/models/news_model.dart';

abstract class NewsLocalDataSource {
  Future<void> cacheNews(List<NewsModel> newsList);
  Future<List<NewsModel>> getCachedNews();
  Future<bool> isCacheValid();
  Future<void> clearNews();

  // Bookmark
  Future<void> addBookmark(NewsModel news);
  Future<void> removeBookmark(String url);
  Future<List<NewsModel>> getBookmarks();
  Future<bool> isBookmarked(String url);
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final NewsDao _newsDao;
  NewsLocalDataSourceImpl(this._newsDao);

  @override
  Future<void> cacheNews(List<NewsModel> n) => _newsDao.cacheNews(n);
  @override
  Future<List<NewsModel>> getCachedNews() => _newsDao.getCachedNews();
  @override
  Future<bool> isCacheValid() => _newsDao.isCacheValid();
  @override
  Future<void> clearNews() => _newsDao.clearNews();
  @override
  Future<void> addBookmark(NewsModel n) => _newsDao.addBookmark(n);
  @override
  Future<void> removeBookmark(String url) => _newsDao.removeBookmark(url);
  @override
  Future<List<NewsModel>> getBookmarks() => _newsDao.getBookmarks();
  @override
  Future<bool> isBookmarked(String url) => _newsDao.isBookmarked(url);
}
