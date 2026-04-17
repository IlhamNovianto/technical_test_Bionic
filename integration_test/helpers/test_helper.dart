import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:technical_test/main.dart' as app;
import 'package:technical_test/presentation/news/news_detail_page.dart';
import 'package:technical_test/presentation/news/news_page.dart';

class TestHelper {
  // ── Setup app ──────────────────────────────────────────────
  static Future<void> setupApp(WidgetTester tester) async {
    try {
      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (_) {}

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));
    int retry = 0;
    while (find.text('Masuk sebagai Tamu').evaluate().isEmpty && retry < 8) {
      await tester.pumpAndSettle(const Duration(seconds: 2));
      retry++;
    }
  }

  // ── Login sebagai tamu ─────────────────────────────────────
  static Future<void> loginAsGuest(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final loginBtn = find.text('Masuk sebagai Tamu');
    expect(
      loginBtn,
      findsOneWidget,
      reason: 'Login Page harus tampil sebelum login',
    );

    await tester.tap(loginBtn);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  // ── Buka news detail ───────────────────────────────────────
  static Future<void> openFirstNews(WidgetTester tester) async {
    // Tunggu berita load
    await tester.pumpAndSettle(const Duration(seconds: 5));

    if (find.byType(NewsListItem).evaluate().isEmpty) {
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    if (find.byType(NewsListItem).evaluate().isEmpty) return;

    await tester.tap(find.byType(NewsListItem).first, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    if (find.byType(NewsDetailPage).evaluate().isNotEmpty) return;

    final byKey = find.byKey(const ValueKey('news_item_0'));
    if (byKey.evaluate().isNotEmpty) {
      await tester.tap(byKey, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (find.byType(NewsDetailPage).evaluate().isNotEmpty) return;
    }

    final titles = find.descendant(
      of: find.byType(NewsListItem).first,
      matching: find.byType(Text),
    );

    if (titles.evaluate().isNotEmpty) {
      await tester.tap(titles.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }
  }

  // ── Tunggu Detail Page dengan timeout ─────────────────────
  static Future<void> waitForDetailPage(WidgetTester tester) async {
    const timeout = Duration(seconds: 10);
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.byType(NewsDetailPage).evaluate().isNotEmpty) return;
    }

    debugPrint('waitForDetailPage: timeout, NewsDetailPage not found');
  }

  // ── Scroll horizontal ke kategori ─────────────────────────
  static Future<void> scrollToCategory(
    WidgetTester tester,
    String category,
  ) async {
    final screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;

    for (int i = 0; i < 3; i++) {
      final finder = find.text(category);
      if (finder.evaluate().isEmpty) break;

      final rect = tester.getRect(finder.first);
      if (rect.right <= screenWidth && rect.left >= 0) break;

      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(-150, 0),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    }
  }

  // ── Teardown ───────────────────────────────────────────────
  static Future<void> tearDown() async {
    try {
      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (_) {}
    Get.reset();
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
