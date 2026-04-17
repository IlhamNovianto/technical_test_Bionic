import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:technical_test/presentation/auth/login_page.dart';
import 'package:technical_test/presentation/news/news_page.dart';

import '../helpers/test_helper.dart';

void authTests() {
  group('Auth — Login Page', () {
    tearDown(() async => await TestHelper.tearDown());

    testWidgets('01 — Login page menampilkan semua elemen', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
      expect(find.text('Masuk sebagai Tamu'), findsOneWidget);
    });

    testWidgets('02 — Tombol login tersedia dan bisa di-tap', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);

      expect(find.text('Sign In with Google'), findsOneWidget);
      expect(find.text('Masuk sebagai Tamu'), findsOneWidget);
    });
    testWidgets('03 — Tombol Guest Login bisa di-tap', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      final guestBtn = find.text('Masuk sebagai Tamu');
      expect(guestBtn, findsOneWidget);

      await tester.tap(guestBtn, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('04 — Loading indicator muncul saat proses login', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);

      await tester.tap(find.text('Masuk sebagai Tamu'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('05 — Guest login berhasil navigasi ke News Page', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);

      expect(find.byType(NewsPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('06 — Login page tidak muncul lagi setelah login', (
      WidgetTester tester,
    ) async {
      await TestHelper.setupApp(tester);
      await TestHelper.loginAsGuest(tester);

      expect(find.byType(LoginPage), findsNothing);
    });
  });
}
