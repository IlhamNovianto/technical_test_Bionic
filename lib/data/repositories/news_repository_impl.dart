import 'package:technical_test/core/utils/connectivity_utils.dart';
import 'package:technical_test/data/datasources/local/news_local_datasource.dart';
import 'package:technical_test/data/datasources/remote/news_remote_datasource.dart';
import 'package:technical_test/data/models/news_model.dart';
import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _remote;
  final NewsLocalDataSource _local;
  final ConnectivityUtils _connectivity;

  NewsRepositoryImpl({
    required NewsRemoteDataSource remote,
    required NewsLocalDataSource local,
    required ConnectivityUtils connectivity,
  }) : _remote = remote,
       _local = local,
       _connectivity = connectivity;

  @override
  Future<List<NewsEntity>> getLatestNews({int page = 1}) async {
    final isOnline = await _connectivity.isConnected();
    if (isOnline) {
      try {
        final result = await _remote.getLatestNews(page: page);
        if (page == 1) {
          await _local.clearNews();
          await _local.cacheNews(result);
        }
        return result;
      } catch (_) {
        return await _local.getCachedNews();
      }
    }
    return await _local.getCachedNews();
  }

  @override
  Future<List<NewsEntity>> getNewsByCategory(
    String category, {
    int page = 1,
  }) async {
    final isOnline = await _connectivity.isConnected();
    if (isOnline) {
      return await _remote.getNewsByCategory(category, page: page);
    }
    return await _local.getCachedNews();
  }

  @override
  Future<List<NewsEntity>> searchNews(String keyword, {int page = 1}) async {
    return await _remote.searchNews(keyword, page: page);
  }

  @override
  Future<List<NewsEntity>> getBookmarks() => _local.getBookmarks();

  @override
  Future<void> addBookmark(NewsEntity news) =>
      _local.addBookmark(NewsModel.fromEntity(news));

  @override
  Future<void> removeBookmark(String url) => _local.removeBookmark(url);

  @override
  Future<bool> isBookmarked(String url) => _local.isBookmarked(url);
}
