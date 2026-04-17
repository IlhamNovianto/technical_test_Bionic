import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technical_test/core/constants/api_constants.dart';
import 'package:technical_test/core/constants/app_routes.dart';
import 'package:technical_test/core/utils/date_utils.dart';
import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/presentation/news/news_controller.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();

    return Scaffold(
      body: Obx(() => _buildBody(context, controller)),

      // ── Bottom Navigation Bar ──────────────────────────────
      bottomNavigationBar: _BottomNav(),
    );
  }

  Widget _buildBody(BuildContext context, NewsController controller) {
    return CustomScrollView(
      slivers: [
        // ── Gradient Header ──────────────────────────────────
        SliverToBoxAdapter(child: _GradientHeader()),

        // ── Category Filter ──────────────────────────────────
        SliverToBoxAdapter(child: _CategoryFilter()),

        // ── Offline Banner ───────────────────────────────────
        if (controller.isOffline.value)
          SliverToBoxAdapter(child: _OfflineBanner()),

        // ── Loading ──────────────────────────────────────────
        if (controller.isLoading.value)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        // ── Error ────────────────────────────────────────────
        else if (controller.errorMessage.value.isNotEmpty &&
            controller.newsList.isEmpty)
          SliverFillRemaining(child: _ErrorWidget())
        // ── News List ─────────────────────────────────────────
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == controller.newsList.length) {
                return controller.isLoadingMore.value
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox(height: 80);
              }
              return NewsListItem(
                key: ValueKey('news_item_$index'),
                news: controller.newsList[index],
              );
            }, childCount: controller.newsList.length + 1),
          ),
      ],
    );
  }
}

// ── Gradient Header ────────────────────────────────────────────
class _GradientHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 22, 45, 174),
            Color.fromARGB(255, 125, 155, 253),
            Color.fromARGB(255, 255, 255, 255),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul + Search icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Top News',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Get.toNamed(AppRoutes.search),
                icon: const Icon(Icons.search, color: Colors.black, size: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Category Filter ────────────────────────────────────────────
class _CategoryFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(
          () => Row(
            children: ApiConstants.categories.map((category) {
              final isSelected = controller.selectedCategory.value == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.selectCategory(category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6C3EE8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6C3EE8)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── News List Item (gambar kiri, konten kanan) ─────────────────
class NewsListItem extends StatelessWidget {
  final NewsEntity news;
  const NewsListItem({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // ✅ InkWell lebih reliable untuk integration test
        onTap: () => Get.toNamed(AppRoutes.newsDetail, arguments: news),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar kiri
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: news.urlToImage ?? '',
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 100,
                    height: 80,
                    color: Colors.grey.shade200,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 100,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Konten kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
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
      ),
    );
  }
}
// class NewsListItem extends StatelessWidget {
//   final NewsEntity news;
//   const NewsListItem({super.key, required this.news});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Get.toNamed(AppRoutes.newsDetail, arguments: news),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Gambar kiri
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: CachedNetworkImage(
//                 imageUrl: news.urlToImage ?? '',
//                 width: 100,
//                 height: 80,
//                 fit: BoxFit.cover,
//                 placeholder: (_, __) => Container(
//                   width: 100,
//                   height: 80,
//                   color: Colors.grey.shade200,
//                 ),
//                 errorWidget: (_, __, ___) => Container(
//                   width: 100,
//                   height: 80,
//                   color: Colors.grey.shade200,
//                   child: const Icon(
//                     Icons.image_not_supported,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),

//             // Konten kanan
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Judul
//                   Text(
//                     news.title,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       height: 1.4,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   // Source + waktu
//                   Row(
//                     children: [
//                       if (news.sourceName != null)
//                         Text(
//                           news.sourceName!,
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       if (news.sourceName != null && news.publishedAt != null)
//                         Text(
//                           ' · ',
//                           style: TextStyle(color: Colors.grey.shade400),
//                         ),
//                       if (news.publishedAt != null)
//                         Text(
//                           AppDateUtils.timeAgo(news.publishedAt!),
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ── Offline Banner ─────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.isDarkMode ? const Color(0xFF3E2723) : const Color(0xFFFFF3E0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: Get.isDarkMode
                ? const Color(0xFFFFCCBC)
                : const Color(0xFFE65100),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode Offline — Menampilkan berita tersimpan',
              style: TextStyle(
                fontSize: 12,
                color: Get.isDarkMode
                    ? const Color(0xFFFFCCBC)
                    : const Color(0xFFE65100),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Get.find<NewsController>().refreshNews(),
            child: Text(
              'Coba Lagi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Get.isDarkMode
                    ? const Color(0xFFFFCCBC)
                    : const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error Widget ────────────────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.refreshNews,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Navigation Bar ──────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final _selectedIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => NavigationBar(
        selectedIndex: _selectedIndex.value,
        onDestinationSelected: (index) {
          _selectedIndex.value = index;
          switch (index) {
            case 0:
              break; // sudah di Home
            case 1:
              Get.toNamed(AppRoutes.search);
              break;
            case 2:
              Get.toNamed(AppRoutes.bookmark);
              break;
            case 3:
              Get.toNamed(AppRoutes.profile);
              break;
          }
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        indicatorColor: const Color(0xFF6C3EE8).withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF6C3EE8)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: Color(0xFF6C3EE8)),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark, color: Color(0xFF6C3EE8)),
            label: 'Bookmark',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF6C3EE8)),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
