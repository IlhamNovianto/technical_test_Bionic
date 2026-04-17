import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technical_test/core/constants/app_routes.dart';
import 'package:technical_test/core/utils/date_utils.dart';
import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/presentation/news/news_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key});

  // ── Helper buka URL ────────────────────────────────────────
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuka link ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final NewsEntity? news = Get.arguments as NewsEntity?;
    if (news == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(child: Text('Berita tidak ditemukan')),
      );
    }

    final NewsController controller = Get.find<NewsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Gambar full ──────────────────────────────
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: news.urlToImage ?? '',
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(height: 300, color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Container(
                        height: 300,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // Overlay gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tombol Back
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // Tombol Bookmark
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      right: 16,
                      child: Obx(() {
                        final isBookmarked = controller.isNewsBookmarked(
                          news.url!,
                        );
                        return GestureDetector(
                          onTap: () => controller.onToggleBookmark(news),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked
                                  ? const Color(0xFF6C3EE8)
                                  : Colors.black87,
                              size: 20,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // ── Konten ────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Source + Tanggal + Badge
                      Row(
                        children: [
                          if (news.sourceName != null)
                            Flexible(
                              child: Text(
                                news.sourceName!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          if (news.sourceName != null &&
                              news.publishedAt != null)
                            Text(
                              ' · ',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          if (news.publishedAt != null)
                            Text(
                              AppDateUtils.formatDate(news.publishedAt!),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE65100),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'News',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Deskripsi
                      if (news.description != null) ...[
                        Text(
                          news.description!,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Konten
                      if (news.content != null)
                        Text(
                          news.content!.replaceAll(
                            RegExp(r'\[\+\d+ chars\]'),
                            '',
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Tombol buka browser
                      if (news.url != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: news.url != null
                                ? () => _launchUrl(news.url!)
                                : null,
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Baca Selengkapnya'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFF6C3EE8)),
                              foregroundColor: const Color(0xFF6C3EE8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── FAB Chat ──────────────────────────────────────
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.chat),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C3EE8), Color(0xFFB06AB3)],
                  ),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
