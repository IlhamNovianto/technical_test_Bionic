import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technical_test/core/constants/app_routes.dart';
import 'package:technical_test/core/utils/date_utils.dart';
import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/presentation/news/news_controller.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _hasText = false.obs;
  DateTime? _lastSearch;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _hasText.value = _searchController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String keyword, NewsController controller) {
    _lastSearch = DateTime.now();
    final capturedTime = _lastSearch;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (capturedTime == _lastSearch) {
        controller.search(keyword);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            controller.clearSearch();
            Get.back();
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari berita...',
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2C)
                : const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),

            suffixIcon: Obx(
              () => _hasText.value
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _hasText.value = false;
                        controller.clearSearch();
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          onChanged: (value) => _onSearchChanged(value, controller),
          onSubmitted: (value) => controller.search(value),
        ),
      ),

      // ── Body ────────────────────────────────────────────────
      body: Obx(() {
        // Loading
        if (controller.isSearching.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!_hasText.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Ketik untuk mencari berita',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Hasil null
        if (controller.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada hasil untuk\n"${controller.searchKeyword.value}"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
          );
        }

        // Ada hasil pencarian
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '${controller.searchResults.length} hasil ditemukan',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  return SearchResultItem(
                    news: controller.searchResults[index],
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Search Result Item ─────────────────────────────────────────
class SearchResultItem extends StatelessWidget {
  final NewsEntity news;
  const SearchResultItem({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (news.url?.isEmpty ?? true) {
          Get.snackbar(
            'Gagal',
            'Link berita tidak tersedia',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade400,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
          );
          return;
        }
        Get.toNamed(AppRoutes.newsDetail, arguments: news);
      },

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
