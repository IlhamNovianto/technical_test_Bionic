import 'package:get/get.dart';
import 'package:technical_test/core/utils/connectivity_utils.dart';
import 'package:technical_test/data/database/app_database.dart';
import 'package:technical_test/data/database/dao/news_dao.dart';
import 'package:technical_test/data/datasources/local/news_local_datasource.dart';
import 'package:technical_test/data/datasources/remote/news_remote_datasource.dart';
import 'package:technical_test/data/repositories/news_repository_impl.dart';
import 'package:technical_test/domain/usecase/get_bookmarks.dart';
import 'package:technical_test/domain/usecase/get_news_by_caategory.dart';
import 'package:technical_test/domain/usecase/get_top_headlines.dart';
import 'package:technical_test/domain/usecase/search_news.dart';
import 'package:technical_test/domain/usecase/toogle_bookmark.dart';

import 'news_controller.dart';

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    final db = AppDatabase();

    // DataSources
    Get.lazyPut<NewsRemoteDataSource>(
      () => NewsRemoteDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<NewsLocalDataSource>(
      () => NewsLocalDataSourceImpl(NewsDao(db)),
      fenix: true,
    );

    // Repository
    Get.lazyPut<NewsRepositoryImpl>(
      () => NewsRepositoryImpl(
        remote: Get.find<NewsRemoteDataSource>(),
        local: Get.find<NewsLocalDataSource>(),
        connectivity: ConnectivityUtils(),
      ),
      fenix: true,
    );

    // Usecases
    Get.lazyPut(
      () => GetTopHeadlines(Get.find<NewsRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut(
      () => GetNewsByCategory(Get.find<NewsRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut(() => SearchNews(Get.find<NewsRepositoryImpl>()), fenix: true);
    Get.lazyPut(
      () => GetBookmarks(Get.find<NewsRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut(
      () => ToggleBookmark(Get.find<NewsRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<ConnectivityUtils>(() => ConnectivityUtils(), fenix: true);

    // Controller
    Get.lazyPut(
      () => NewsController(
        getTopHeadlines: Get.find<GetTopHeadlines>(),
        getNewsByCategory: Get.find<GetNewsByCategory>(),
        searchNews: Get.find<SearchNews>(),
        getBookmarks: Get.find<GetBookmarks>(),
        toggleBookmark: Get.find<ToggleBookmark>(),
        connectivity: Get.find<ConnectivityUtils>(),
      ),
      fenix: true,
    );
  }
}
