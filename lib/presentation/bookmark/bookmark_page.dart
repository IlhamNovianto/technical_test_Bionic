import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technical_test/core/constants/app_routes.dart';
import 'package:technical_test/core/utils/date_utils.dart';
import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/presentation/news/news_controller.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Bookmark',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
      ),

      body: Obx(() {
        // Kosong
        if (controller.bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 72,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada berita tersimpan',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap ikon bookmark di berita\nyang ingin kamu simpan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        // List bookmark
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.bookmarks.length,
          itemBuilder: (context, index) {
            return BookmarkItem(
              news: controller.bookmarks[index],
              controller: controller,
            );
          },
        );
      }),
    );
  }
}

class BookmarkItem extends StatelessWidget {
  final NewsEntity news;
  final NewsController controller;

  const BookmarkItem({super.key, required this.news, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Swipe kiri untuk hapus bookmark
      key: Key(news.url ?? news.title),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        if (news.url != null) {
          controller.onToggleBookmark(news);
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.newsDetail, arguments: news),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2C)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: news.urlToImage ?? '',
                  width: 80,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 80,
                    height: 70,
                    color: Colors.grey.shade200,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 80,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (news.sourceName != null)
                          Text(
                            news.sourceName!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        if (news.sourceName != null && news.publishedAt != null)
                          Text(
                            ' · ',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        if (news.publishedAt != null)
                          Text(
                            AppDateUtils.timeAgo(news.publishedAt!),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Hint swipe
                    Row(
                      children: [
                        Icon(
                          Icons.swipe_left,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Geser untuk hapus',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tombol bookmark (untuk hapus)
              IconButton(
                onPressed: () => controller.onToggleBookmark(news),
                icon: const Icon(
                  Icons.bookmark,
                  color: Color(0xFF6C3EE8),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
