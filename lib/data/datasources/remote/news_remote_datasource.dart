import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getLatestNews({int page = 1});
  Future<List<NewsModel>> getNewsByCategory(String category, {int page = 1});
  Future<List<NewsModel>> searchNews(String keyword, {int page = 1});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio _dio;

  NewsRemoteDataSourceImpl({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  @override
  Future<List<NewsModel>> getLatestNews({int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.topHeadlines,
      queryParameters: {
        'country': ApiConstants.defaultCountry,
        'page': page,
        'pageSize': ApiConstants.pageSize,
        'apiKey': ApiConstants.apiKey,
      },
    );
    return _parseArticles(response);
  }

  @override
  Future<List<NewsModel>> getNewsByCategory(
    String category, {
    int page = 1,
  }) async {
    final sourcesResponse = await _dio.get(
      ApiConstants.sources,
      queryParameters: {
        'category': category.toLowerCase(),
        'apiKey': ApiConstants.apiKey,
      },
    );

    final sources = sourcesResponse.data['sources'] as List;
    if (sources.isEmpty) return [];

    final sourceIds = sources.take(5).map((s) => s['id'].toString()).join(',');

    final articlesResponse = await _dio.get(
      ApiConstants.topHeadlines,
      queryParameters: {
        'sources': sourceIds,
        'page': page,
        'pageSize': ApiConstants.pageSize,
        'apiKey': ApiConstants.apiKey,
      },
    );

    return _parseArticles(articlesResponse);
  }

  @override
  Future<List<NewsModel>> searchNews(String keyword, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.everything,
      queryParameters: {
        'q': keyword,
        'page': page,
        'pageSize': ApiConstants.pageSize,
        'sortBy': 'publishedAt',
        'apiKey': ApiConstants.apiKey,
      },
    );
    return _parseArticles(response);
  }

  List<NewsModel> _parseArticles(Response response) {
    if (response.statusCode == 200) {
      final articles = response.data['articles'] as List? ?? [];
      return articles
          .map((json) {
            try {
              return NewsModel.fromJson(json as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<NewsModel>()
          .where(
            (n) =>
                n.title.isNotEmpty &&
                n.title != '[Removed]' &&
                (n.url?.isNotEmpty ?? false),
          )
          .toList();
    }
    throw Exception('Gagal mengambil berita: ${response.statusCode}');
  }
}
