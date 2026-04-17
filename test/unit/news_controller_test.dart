import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:technical_test/core/utils/connectivity_utils.dart';
import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/domain/usecase/get_bookmarks.dart';
import 'package:technical_test/domain/usecase/get_news_by_caategory.dart';
import 'package:technical_test/domain/usecase/get_top_headlines.dart';
import 'package:technical_test/domain/usecase/search_news.dart';
import 'package:technical_test/domain/usecase/toogle_bookmark.dart';
import 'package:technical_test/presentation/news/news_controller.dart';

// ── Manual Mock ────────────────────────────────────────────────
class MockGetTopHeadlines extends Mock implements GetTopHeadlines {
  @override
  Future<List<NewsEntity>> call({int? page = 1}) =>
      super.noSuchMethod(
            Invocation.method(#call, [], {#page: page}),
            returnValue: Future.value(<NewsEntity>[]),
            returnValueForMissingStub: Future.value(<NewsEntity>[]),
          )
          as Future<List<NewsEntity>>;
}

class MockGetNewsByCategory extends Mock implements GetNewsByCategory {
  @override
  Future<List<NewsEntity>> call(String? category, {int? page = 1}) =>
      super.noSuchMethod(
            Invocation.method(#call, [category], {#page: page}),
            returnValue: Future.value(<NewsEntity>[]),
            returnValueForMissingStub: Future.value(<NewsEntity>[]),
          )
          as Future<List<NewsEntity>>;
}

class MockSearchNews extends Mock implements SearchNews {
  @override
  Future<List<NewsEntity>> call(String? keyword, {int? page = 1}) =>
      super.noSuchMethod(
            Invocation.method(#call, [keyword], {#page: page}),
            returnValue: Future.value(<NewsEntity>[]),
            returnValueForMissingStub: Future.value(<NewsEntity>[]),
          )
          as Future<List<NewsEntity>>;
}

class MockGetBookmarks extends Mock implements GetBookmarks {
  @override
  Future<List<NewsEntity>> call() =>
      super.noSuchMethod(
            Invocation.method(#call, []),
            returnValue: Future.value(<NewsEntity>[]),
            returnValueForMissingStub: Future.value(<NewsEntity>[]),
          )
          as Future<List<NewsEntity>>;
}

class MockToggleBookmark extends Mock implements ToggleBookmark {
  @override
  Future<void> call(NewsEntity? news) =>
      super.noSuchMethod(
            Invocation.method(#call, [news]),
            returnValue: Future.value(),
            returnValueForMissingStub: Future.value(),
          )
          as Future<void>;
}

// ── Dummy data ─────────────────────────────────────────────────
const fakeNews = NewsEntity(
  sourceName: 'BBC News',
  author: 'Test Author',
  title: 'Flutter Released with Major Updates',
  description: 'Flutter team announced major updates.',
  url: 'https://example.com/news/flutter',
  publishedAt: '2024-11-01T10:00:00Z',
);

const fakeNewsNoUrl = NewsEntity(title: 'Article Without URL', url: null);

class MockConnectivity extends Mock implements ConnectivityUtils {
  @override
  Future<bool> isConnected() =>
      super.noSuchMethod(
            Invocation.method(#isConnected, []),
            returnValue: Future.value(true),
            returnValueForMissingStub: Future.value(true),
          )
          as Future<bool>;

  @override
  Stream<bool> get onConnectivityChanged =>
      super.noSuchMethod(
            Invocation.getter(#onConnectivityChanged),
            returnValue: Stream.value(true),
            returnValueForMissingStub: Stream.value(true),
          )
          as Stream<bool>;
}

// ── Tests ──────────────────────────────────────────────────────
void main() {
  late NewsController controller;
  late MockGetTopHeadlines mockGetTopHeadlines;
  late MockGetNewsByCategory mockGetNewsByCategory;
  late MockSearchNews mockSearchNews;
  late MockGetBookmarks mockGetBookmarks;
  late MockToggleBookmark mockToggleBookmark;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockGetTopHeadlines = MockGetTopHeadlines();
    mockGetNewsByCategory = MockGetNewsByCategory();
    mockSearchNews = MockSearchNews();
    mockGetBookmarks = MockGetBookmarks();
    mockToggleBookmark = MockToggleBookmark();
    mockConnectivity = MockConnectivity();

    when(
      mockGetTopHeadlines(page: anyNamed('page')),
    ).thenAnswer((_) async => []);
    when(mockGetBookmarks()).thenAnswer((_) async => []);
    when(mockConnectivity.isConnected()).thenAnswer((_) async => true);
    when(
      mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => Stream.value(true));

    controller = NewsController(
      getTopHeadlines: mockGetTopHeadlines,
      getNewsByCategory: mockGetNewsByCategory,
      searchNews: mockSearchNews,
      getBookmarks: mockGetBookmarks,
      toggleBookmark: mockToggleBookmark,
      connectivity: mockConnectivity,
    );

    Get.testMode = true;
  });

  tearDown(() => Get.reset());

  group('NewsController — State Awal', () {
    test('newsList awalnya kosong', () {
      expect(controller.newsList, isEmpty);
    });

    test('selectedCategory awalnya Latest', () {
      expect(controller.selectedCategory.value, 'Latest');
    });

    test('isLoading awalnya false', () {
      expect(controller.isLoading.value, false);
    });

    test('isOffline awalnya false', () {
      expect(controller.isOffline.value, false);
    });

    test('searchKeyword awalnya kosong', () {
      expect(controller.searchKeyword.value, isEmpty);
    });
  });

  group('NewsController — Fetch News', () {
    test('fetchNews berhasil mengisi newsList', () async {
      when(
        mockGetTopHeadlines(page: anyNamed('page')),
      ).thenAnswer((_) async => [fakeNews]);

      await controller.fetchNews();

      expect(controller.newsList, isNotEmpty);
      expect(controller.newsList.length, 1);
      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
    });

    test('fetchNews gagal mengisi errorMessage', () async {
      when(
        mockGetTopHeadlines(page: anyNamed('page')),
      ).thenThrow(Exception('Network error'));

      await controller.fetchNews();

      expect(controller.errorMessage.value, isNotEmpty);
      expect(controller.isLoading.value, false);
      expect(controller.newsList, isEmpty);
    });

    test('refresh mereset list dan fetch ulang', () async {
      when(
        mockGetTopHeadlines(page: anyNamed('page')),
      ).thenAnswer((_) async => [fakeNews]);

      await controller.fetchNews();
      expect(controller.newsList.length, 1);

      await controller.refreshNews();
      expect(controller.newsList.length, 1);
    });
  });

  group('NewsController — Category', () {
    test('selectCategory mengubah selectedCategory', () async {
      when(
        mockGetNewsByCategory(any, page: anyNamed('page')),
      ).thenAnswer((_) async => [fakeNews]);

      await controller.selectCategory('Technology');

      expect(controller.selectedCategory.value, 'Technology');
    });

    test('selectCategory memanggil getNewsByCategory', () async {
      when(
        mockGetNewsByCategory(any, page: anyNamed('page')),
      ).thenAnswer((_) async => [fakeNews]);

      await controller.selectCategory('Sports');

      verify(mockGetNewsByCategory('Sports', page: 1)).called(1);
    });

    test('selectCategory sama tidak fetch ulang', () async {
      await controller.selectCategory('Latest');

      verifyNever(mockGetNewsByCategory(any));
    });
  });

  group('NewsController — Search', () {
    test('search berhasil mengisi searchResults', () async {
      when(
        mockSearchNews(any, page: anyNamed('page')),
      ).thenAnswer((_) async => [fakeNews]);

      await controller.search('flutter');

      expect(controller.searchResults, isNotEmpty);
      expect(controller.searchKeyword.value, 'flutter');
      expect(controller.isSearching.value, false);
    });

    test('search keyword kosong membersihkan searchResults', () async {
      await controller.search('');

      expect(controller.searchResults, isEmpty);
      expect(controller.searchKeyword.value, isEmpty);
    });

    test('clearSearch membersihkan searchResults dan keyword', () async {
      when(
        mockSearchNews(any, page: anyNamed('page')),
      ).thenAnswer((_) async => [fakeNews]);

      await controller.search('flutter');
      expect(controller.searchResults, isNotEmpty);

      controller.clearSearch();

      expect(controller.searchResults, isEmpty);
      expect(controller.searchKeyword.value, isEmpty);
    });

    test('search gagal membersihkan searchResults', () async {
      when(
        mockSearchNews(any, page: anyNamed('page')),
      ).thenThrow(Exception('Network error'));

      await controller.search('error');

      expect(controller.searchResults, isEmpty);
      expect(controller.isSearching.value, false);
    });
  });

  group('NewsController — Bookmark', () {
    test('isNewsBookmarked return false jika belum di-bookmark', () {
      expect(controller.isNewsBookmarked('https://example.com'), false);
    });

    test('isNewsBookmarked return false jika url null', () {
      expect(controller.isNewsBookmarked(null), false);
    });

    test('onToggleBookmark skip jika url null', () async {
      await controller.onToggleBookmark(fakeNewsNoUrl);

      verifyNever(mockToggleBookmark(any));
    });

    test('onToggleBookmark berhasil jika url ada', () async {
      when(mockToggleBookmark(any)).thenAnswer((_) async => {});
      when(mockGetBookmarks()).thenAnswer((_) async => [fakeNews]);

      await controller.onToggleBookmark(fakeNews);

      verify(mockToggleBookmark(fakeNews)).called(1);
    });

    test('bookmarks terupdate setelah toggle', () async {
      when(mockToggleBookmark(any)).thenAnswer((_) async => {});
      when(mockGetBookmarks()).thenAnswer((_) async => [fakeNews]);

      await controller.onToggleBookmark(fakeNews);

      expect(controller.bookmarks, isNotEmpty);
      expect(controller.isNewsBookmarked(fakeNews.url), true);
    });
  });
}
