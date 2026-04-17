import 'package:get/get.dart';
import 'package:technical_test/core/utils/connectivity_utils.dart';
import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/domain/usecase/get_bookmarks.dart';
import 'package:technical_test/domain/usecase/get_news_by_caategory.dart';
import 'package:technical_test/domain/usecase/get_top_headlines.dart';
import 'package:technical_test/domain/usecase/search_news.dart';
import 'package:technical_test/domain/usecase/toogle_bookmark.dart';

class NewsController extends GetxController {
  final GetTopHeadlines getTopHeadlines;
  final GetNewsByCategory getNewsByCategory;
  final SearchNews searchNews;
  final GetBookmarks getBookmarks;
  final ToggleBookmark toggleBookmark;
  final ConnectivityUtils connectivity;

  NewsController({
    required this.getTopHeadlines,
    required this.getNewsByCategory,
    required this.searchNews,
    required this.getBookmarks,
    required this.toggleBookmark,
    required this.connectivity,
  });

  // ── State ──────────────────────────────────────────────────
  final newsList = <NewsEntity>[].obs;
  final bookmarks = <NewsEntity>[].obs;
  final searchResults = <NewsEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSearching = false.obs;
  final isOffline = false.obs;
  final errorMessage = ''.obs;
  final selectedCategory = 'Latest'.obs;
  final searchKeyword = ''.obs;

  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchNews();
    loadBookmarks();
    _listenConnectivity();
  }

  void _listenConnectivity() {
    connectivity.onConnectivityChanged.listen((connected) {
      if (connected && isOffline.value) refreshNews();
      isOffline.value = !connected;
    });
  }

  Future<void> fetchNews({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      newsList.clear();
    }
    if (!_hasMore) return;

    _currentPage == 1 ? isLoading.value = true : isLoadingMore.value = true;
    errorMessage.value = '';

    try {
      final connected = await connectivity.isConnected();
      isOffline.value = !connected;

      List<NewsEntity> result;

      if (selectedCategory.value == 'Latest') {
        result = await getTopHeadlines(page: _currentPage);
      } else {
        result = await getNewsByCategory(
          selectedCategory.value,
          page: _currentPage,
        );
      }

      if (result.isEmpty) {
        _hasMore = false;
      } else {
        newsList.addAll(result);
        _currentPage++;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat berita.';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ── Ganti kategori ─────────────────────────────────────────
  Future<void> selectCategory(String category) async {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    await fetchNews(isRefresh: true);
  }

  // ── Search ─────────────────────────────────────────────────
  Future<void> search(String keyword) async {
    if (keyword.trim().isEmpty) {
      searchResults.clear();
      searchKeyword.value = ''; // ← reset jika kosong
      return;
    }

    isSearching.value = true;
    searchKeyword.value = keyword; //

    try {
      final result = await searchNews(keyword);
      searchResults.assignAll(result);
    } catch (e) {
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    searchResults.clear();
    searchKeyword.value = '';
  }

  // ── Bookmark ───────────────────────────────────────────────
  Future<void> loadBookmarks() async {
    final result = await getBookmarks();
    bookmarks.assignAll(result);
  }

  Future<void> onToggleBookmark(NewsEntity news) async {
    if (news.url == null) return;
    await toggleBookmark(news);
    await loadBookmarks();
  }

  bool isNewsBookmarked(String? url) {
    if (url == null) return false;
    return bookmarks.any((b) => b.url == url);
  }

  Future<void> refreshNews() => fetchNews(isRefresh: true);
}
