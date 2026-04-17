import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technical_test/core/constants/app_routes.dart';
import 'package:technical_test/core/theme/app_theme.dart';
import 'package:technical_test/core/theme/theme_controller.dart';
import 'package:technical_test/data/datasources/remote/auth_remote_datasource.dart';
import 'package:technical_test/data/repositories/auth_repository_impl.dart';
import 'package:technical_test/presentation/auth/auth_binding.dart';
import 'package:technical_test/presentation/auth/auth_controller.dart';
import 'package:technical_test/presentation/auth/login_page.dart';
import 'package:technical_test/presentation/bookmark/bookmark_page.dart';
import 'package:technical_test/presentation/chat/chat_binding.dart';
import 'package:technical_test/presentation/chat/chat_page.dart';
import 'package:technical_test/presentation/chat/widgets/image_preview.dart';
import 'package:technical_test/presentation/news/news_binding.dart';
import 'package:technical_test/presentation/news/news_detail_page.dart';
import 'package:technical_test/presentation/news/news_page.dart';
import 'package:technical_test/presentation/profile/profile_page.dart';
import 'package:technical_test/presentation/search/search_page.dart';

import 'firebase_options.dart';

void main({bool isTest = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!isTest) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Get.put(ThemeController(), permanent: true);
  Get.put(
    AuthController(AuthRepositoryImpl(AuthRemoteDataSourceImpl())),
    permanent: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'News App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode,

        // ✅ Selalu mulai dari login page
        // Biarkan AuthController yang handle redirect
        initialRoute: AppRoutes.login,

        // ✅ Tambah builder untuk handle sesi Firebase
        builder: (context, child) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              return child ?? const SizedBox.shrink();
            },
          );
        },
        getPages: [
          GetPage(
            name: AppRoutes.login,
            page: () => const LoginPage(),
            binding: AuthBinding(),
          ),
          GetPage(
            name: AppRoutes.news,
            page: () => const NewsPage(),
            binding: NewsBinding(),
          ),
          GetPage(
            name: AppRoutes.newsDetail,
            page: () => const NewsDetailPage(),
          ),
          GetPage(
            name: AppRoutes.chat,
            page: () => const ChatPage(),
            binding: ChatBinding(),
          ),
          GetPage(
            name: AppRoutes.imagePreview,
            page: () => const ImagePreviewPage(),
          ),

          GetPage(name: AppRoutes.search, page: () => const SearchPage()),
          GetPage(name: AppRoutes.bookmark, page: () => const BookmarkPage()),
          GetPage(name: AppRoutes.profile, page: () => const ProfilePage()),
        ],
      ),
    );
  }
}
