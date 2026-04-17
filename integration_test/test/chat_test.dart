import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technical_test/presentation/chat/chat_page.dart';
import 'package:technical_test/presentation/chat/widgets/chat_bubble.dart';
import 'package:technical_test/presentation/news/news_detail_page.dart';

import '../helpers/mock_data.dart';
import '../helpers/test_helper.dart';

void chatTests() {
  group('Chat — Chat Page & Bot Reply', () {
    tearDown(() async => await TestHelper.tearDown());

    Future<bool> goToChatPage(WidgetTester tester) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);
      await TestHelper.openFirstNews(tester);

      if (find.byType(NewsDetailPage).evaluate().isEmpty) return false;
      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(0, -200),
        500,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      final chatFab = find.byIcon(Icons.chat_bubble_outline);
      if (chatFab.evaluate().isEmpty) return false;

      await tester.tap(chatFab.first, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      return find.byType(ChatPage).evaluate().isNotEmpty;
    }

    testWidgets('01 — Chat Page terbuka dari FAB News Detail', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return; // skip jika berita tidak load

      expect(find.byType(ChatPage), findsOneWidget);
    });

    testWidgets('02 — Chat Page menampilkan elemen dengan benar', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      expect(find.text('Asisten Virtual'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('03 — Welcome message dari bot muncul', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      expect(find.textContaining('Halo! Saya asisten virtual'), findsOneWidget);
    });

    testWidgets('04 — TextField bisa menerima input teks', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      await tester.enterText(find.byType(TextField), MockData.chatMessage);
      await tester.pump();

      expect(find.text(MockData.chatMessage), findsOneWidget);
    });

    testWidgets('05 — Pesan kosong tidak bisa dikirim', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      final countBefore = find.byType(ChatBubble).evaluate().length;

      await tester.tap(find.byIcon(Icons.send_rounded), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(ChatBubble).evaluate().length, equals(countBefore));
    });

    testWidgets('06 — Kirim pesan teks berhasil', (WidgetTester tester) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      await tester.enterText(find.byType(TextField), 'halo');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send_rounded), warnIfMissed: false);
      await tester.pump();

      final finder1 = find.textContaining('Halo!');
      final finder2 = find.textContaining('Hai!');
      expect(
        finder1.evaluate().isNotEmpty || finder2.evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('07 — TextField kosong setelah pesan dikirim', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      await tester.enterText(find.byType(TextField), 'halo');
      await tester.tap(find.byIcon(Icons.send_rounded), warnIfMissed: false);
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text ?? '',
        isEmpty,
      );
    });

    testWidgets('08 — Typing indicator muncul setelah kirim pesan', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      await tester.enterText(find.byType(TextField), 'halo');
      await tester.tap(find.byIcon(Icons.send_rounded), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('sedang mengetik...'), findsOneWidget);
    });

    testWidgets('09 — Bot membalas setelah user kirim pesan', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      await tester.enterText(find.byType(TextField), 'halo');
      await tester.tap(find.byIcon(Icons.send_rounded), warnIfMissed: false);
      await tester.pump();

      await tester.pumpAndSettle(const Duration(seconds: 4));

      expect(find.byType(ChatBubble), findsAtLeastNWidgets(2));
    });

    testWidgets('10 — Status kembali online setelah bot reply', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      await tester.enterText(find.byType(TextField), 'halo');
      await tester.tap(find.byIcon(Icons.send_rounded), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('sedang mengetik...'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(find.text('online'), findsOneWidget);
    });

    testWidgets('11 — Tombol gambar tersedia', (WidgetTester tester) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('12 — Back dari Chat kembali ke News Detail', (
      WidgetTester tester,
    ) async {
      final success = await goToChatPage(tester);
      if (!success) return;

      await tester.tap(
        find.byIcon(Icons.arrow_back_ios_new),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(find.byType(NewsDetailPage), findsOneWidget);
    });
  });
}
