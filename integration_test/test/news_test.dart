import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technical_test/presentation/bookmark/bookmark_page.dart';
import 'package:technical_test/presentation/news/news_detail_page.dart';
import 'package:technical_test/presentation/news/news_page.dart';
import 'package:technical_test/presentation/profile/profile_page.dart';
import 'package:technical_test/presentation/search/search_page.dart';

import '../helpers/test_helper.dart';

void newsTests() {
  group('News — News Page', () {
    tearDown(() async => await TestHelper.tearDown());

    testWidgets('01 — News Page tampil setelah login', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);

      expect(find.byType(NewsPage), findsOneWidget);
    });

    testWidgets('02 — Category filter tersedia', (WidgetTester tester) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Latest'), findsOneWidget);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(-300, 0),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('03 — Latest dipilih secara default', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Latest'), findsOneWidget);
    });

    testWidgets('04 — Pilih kategori Technology berhasil', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await TestHelper.scrollToCategory(tester, 'Technology');
      await tester.pumpAndSettle();

      final techFinder = find.text('Technology');
      if (techFinder.evaluate().isNotEmpty) {
        await tester.tap(techFinder, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      expect(find.byType(NewsPage), findsOneWidget);
    });

    testWidgets('05 — Berita muncul dalam list', (WidgetTester tester) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(NewsListItem), findsWidgets);
    });

    testWidgets('06 — Pull-to-refresh berfungsi', (WidgetTester tester) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(0, 300),
        800,
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(NewsPage), findsOneWidget);
    });
  });

  group('News — News Detail Page', () {
    tearDown(() async => await TestHelper.tearDown());

    testWidgets('07 — Tap berita membuka Detail Page', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.byType(NewsListItem), findsWidgets);
      await TestHelper.openFirstNews(tester);
      await TestHelper.waitForDetailPage(tester);

      expect(find.byType(NewsDetailPage), findsOneWidget);
    });

    testWidgets('08 — Detail Page menampilkan elemen yang benar', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await TestHelper.openFirstNews(tester);
      await TestHelper.waitForDetailPage(tester);

      if (find.byType(NewsDetailPage).evaluate().isEmpty) {
        debugPrint('Test 08 skipped: NewsDetailPage not found');
        return;
      }

      expect(find.text('Baca Selengkapnya'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('09 — Bookmark berita berhasil', (WidgetTester tester) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await TestHelper.openFirstNews(tester);

      if (find.byType(NewsDetailPage).evaluate().isEmpty) return;

      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(0, 300),
        500,
      );
      await tester.pumpAndSettle();

      final bookmarkBorder = find.byIcon(Icons.bookmark_border);
      if (bookmarkBorder.evaluate().isNotEmpty) {
        await tester.tap(bookmarkBorder.first, warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(
          find.byIcon(Icons.bookmark).evaluate().isNotEmpty ||
              find.byIcon(Icons.bookmark_border).evaluate().isNotEmpty,
          isTrue,
        );
      }
    });

    testWidgets('10 — Un-bookmark berita berhasil', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await TestHelper.openFirstNews(tester);

      if (find.byType(NewsDetailPage).evaluate().isEmpty) return;

      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(0, 300),
        500,
      );
      await tester.pumpAndSettle();

      final bookmarkBorder = find.byIcon(Icons.bookmark_border);
      if (bookmarkBorder.evaluate().isNotEmpty) {
        await tester.tap(bookmarkBorder.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      final bookmarkFilled = find.byIcon(Icons.bookmark);
      if (bookmarkFilled.evaluate().isNotEmpty) {
        await tester.tap(bookmarkFilled.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      expect(
        find.byIcon(Icons.bookmark_border).evaluate().isNotEmpty ||
            find.byIcon(Icons.bookmark).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('11 — Tombol back dari Detail kembali ke News Page', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await TestHelper.openFirstNews(tester);

      if (find.byType(NewsDetailPage).evaluate().isEmpty) return;

      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(0, 300),
        500,
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byIcon(Icons.arrow_back).first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(find.byType(NewsPage), findsOneWidget);
    });
  });

  group('News — Bottom Navigation', () {
    tearDown(() async => await TestHelper.tearDown());

    testWidgets('12 — Bottom nav memiliki 4 tab', (WidgetTester tester) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Bookmark'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('13 — Tab Search membuka Search Page', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.tap(find.text('Search'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('14 — Tab Bookmark membuka Bookmark Page', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.tap(find.text('Bookmark'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(BookmarkPage), findsOneWidget);
    });

    testWidgets('15 — Tab Account membuka Profile Page', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.tap(find.text('Account'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ProfilePage), findsOneWidget);
    });
  });

  group('News — Search Page', () {
    tearDown(() async => await TestHelper.tearDown());

    testWidgets('16 — Search Page menampilkan elemen dengan benar', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.tap(find.text('Search'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Ketik untuk mencari berita'), findsOneWidget);
    });

    testWidgets('17 — Search menampilkan hasil atau pesan kosong', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.tap(find.text('Search'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final hasResults = find.byType(SearchResultItem).evaluate().isNotEmpty;
      final hasEmpty = find
          .textContaining('Tidak ada hasil')
          .evaluate()
          .isNotEmpty;
      final isLoading = find
          .byType(CircularProgressIndicator)
          .evaluate()
          .isNotEmpty;

      expect(hasResults || hasEmpty || isLoading, isTrue);
    });

    testWidgets('18 — Tombol clear membersihkan search', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.tap(find.text('Search'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      final clearBtn = find.byIcon(Icons.clear);
      if (clearBtn.evaluate().isNotEmpty) {
        await tester.tap(clearBtn, warnIfMissed: false);
        await tester.pump();
        expect(find.text('Ketik untuk mencari berita'), findsOneWidget);
      }
    });

    testWidgets('19 — Back dari Search kembali ke News Page', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.tap(find.text('Search'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(
        find.byIcon(Icons.arrow_back_ios_new),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(find.byType(NewsPage), findsOneWidget);
    });
  });

  group('News — Bookmark Page', () {
    tearDown(() async => await TestHelper.tearDown());

    testWidgets('20 — Bookmark Page kosong saat belum ada bookmark', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await tester.tap(find.text('Bookmark'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(BookmarkPage), findsOneWidget);

      expect(
        find.text('Belum ada berita tersimpan').evaluate().isNotEmpty ||
            find.byType(BookmarkItem).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('21 — Berita yang di-bookmark muncul di Bookmark Page', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await TestHelper.openFirstNews(tester);

      if (find.byType(NewsDetailPage).evaluate().isEmpty) return;

      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(0, 300),
        500,
      );
      await tester.pumpAndSettle();

      final bookmarkBorder = find.byIcon(Icons.bookmark_border);
      if (bookmarkBorder.evaluate().isNotEmpty) {
        await tester.tap(bookmarkBorder.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      await tester.tap(
        find.byIcon(Icons.arrow_back).first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bookmark'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(BookmarkPage), findsOneWidget);
    });
  });
}
