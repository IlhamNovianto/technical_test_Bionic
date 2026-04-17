import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:technical_test/presentation/auth/login_page.dart';
import 'package:technical_test/presentation/bookmark/bookmark_page.dart';
import 'package:technical_test/presentation/chat/chat_page.dart';
import 'package:technical_test/presentation/chat/widgets/chat_bubble.dart';
import 'package:technical_test/presentation/news/news_detail_page.dart';
import 'package:technical_test/presentation/news/news_page.dart';
import 'package:technical_test/presentation/profile/profile_page.dart';
import 'package:technical_test/presentation/search/search_page.dart';

import '../helpers/test_helper.dart';

void fullFlowTests() {
  group('Full Flow — Alur Lengkap Pengguna', () {
    tearDown(() async => await TestHelper.tearDown());

    testWidgets('Full Flow — Login → News → Category → Detail → '
        'Bookmark → Search → Chat → Profile → Logout', (
      WidgetTester tester,
    ) async {
      // ✅ Step 0: Force logout & reset GetX dulu
      try {
        await FirebaseAuth.instance.signOut();
        Get.reset();
        await Future.delayed(const Duration(seconds: 1));
      } catch (_) {}

      // ✅ Step 1: Setup app & tunggu Login Page
      await TestHelper.setupApp(tester);

      // Tunggu sampai Login Page benar-benar muncul
      int retry = 0;
      while (find.byType(LoginPage).evaluate().isEmpty && retry < 10) {
        await tester.pumpAndSettle(const Duration(seconds: 2));
        retry++;
      }

      // Verifikasi di Login Page
      expect(
        find.byType(LoginPage),
        findsOneWidget,
        reason: 'Harus mulai dari Login Page',
      );
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
      expect(find.text('Masuk sebagai Tamu'), findsOneWidget);

      // ── Step 2: Login ──────────────────────────────────
      await tester.tap(find.text('Masuk sebagai Tamu'), warnIfMissed: false);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(NewsPage), findsOneWidget);

      // ── Step 3: Verifikasi Bottom Nav ──────────────────
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Bookmark'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);

      // ── Step 4: Tunggu berita load ─────────────────────
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ── Step 5: Pilih kategori ─────────────────────────
      await TestHelper.scrollToCategory(tester, 'Technology');
      final techFinder = find.text('Technology');
      if (techFinder.evaluate().isNotEmpty) {
        await tester.tap(techFinder, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // ── Step 6: Buka berita pertama ────────────────────
      await TestHelper.openFirstNews(tester);
      await TestHelper.waitForDetailPage(tester);

      final isDetailOpen = find.byType(NewsDetailPage).evaluate().isNotEmpty;

      if (isDetailOpen) {
        // ── Step 7: Bookmark berita ───────────────────────
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

        // ── Step 8: Kembali ke News ───────────────────────
        final backBtn = find.byIcon(Icons.arrow_back);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }
      }

      expect(find.byType(NewsPage), findsOneWidget);

      // ── Step 9: Buka Search ────────────────────────────
      await tester.tap(find.text('Search'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(SearchPage), findsOneWidget);

      // ── Step 10: Ketik keyword ─────────────────────────
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ── Step 11: Kembali ke News ───────────────────────
      await tester.tap(
        find.byIcon(Icons.arrow_back_ios_new),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.byType(NewsPage), findsOneWidget);

      // ── Step 12: Buka Bookmark ─────────────────────────
      await tester.tap(find.text('Bookmark'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(BookmarkPage), findsOneWidget);

      await tester.tap(
        find.byIcon(Icons.arrow_back_ios_new),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(find.byType(NewsPage), findsOneWidget);

      // ── Step 13: Buka Chat dari Detail ────────────────
      await TestHelper.openFirstNews(tester);
      await TestHelper.waitForDetailPage(tester);

      if (find.byType(NewsDetailPage).evaluate().isNotEmpty) {
        // Scroll ke bawah untuk FAB chat
        await tester.fling(
          find.byType(CustomScrollView).first,
          const Offset(0, -200),
          500,
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        final chatFab = find.byIcon(Icons.chat_bubble_outline);
        if (chatFab.evaluate().isNotEmpty) {
          await tester.tap(chatFab.first, warnIfMissed: false);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }

        if (find.byType(ChatPage).evaluate().isNotEmpty) {
          // ── Step 14: Kirim pesan ──────────────────────
          await tester.enterText(find.byType(TextField), 'halo');
          await tester.tap(
            find.byIcon(Icons.send_rounded),
            warnIfMissed: false,
          );
          await tester.pump();
          // expect(find.textContaining('halo'), findsWidgets);

          final finder1 = find.textContaining('Halo!');
          final finder2 = find.textContaining('Hai!');

          expect(
            finder1.evaluate().isNotEmpty || finder2.evaluate().isNotEmpty,
            true,
          );

          await tester.pump(const Duration(milliseconds: 200));
          expect(find.text('sedang mengetik...'), findsOneWidget);

          await tester.pumpAndSettle(const Duration(seconds: 4));
          expect(find.byType(ChatBubble), findsAtLeastNWidgets(2));

          // ── Step 15: Back dari Chat ───────────────────
          await tester.tap(
            find.byIcon(Icons.arrow_back_ios_new),
            warnIfMissed: false,
          );
          await tester.pumpAndSettle();
        }

        // Back dari Detail
        if (find.byType(NewsDetailPage).evaluate().isNotEmpty) {
          await tester.tap(
            find.byIcon(Icons.arrow_back).first,
            warnIfMissed: false,
          );
          await tester.pumpAndSettle();
        }
      }

      // ── Step 16: Buka Profile ──────────────────────────
      await tester.tap(find.text('Account'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      // ── Step 17: Logout ────────────────────────────────
      await tester.tap(find.text('Logout'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.text('Apakah kamu yakin ingin keluar dari aplikasi?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Logout').last, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ✅ Verifikasi kembali ke Login Page
      int retryLogout = 0;
      while (find.byType(LoginPage).evaluate().isEmpty && retryLogout < 5) {
        await tester.pumpAndSettle(const Duration(seconds: 2));
        retryLogout++;
      }

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
