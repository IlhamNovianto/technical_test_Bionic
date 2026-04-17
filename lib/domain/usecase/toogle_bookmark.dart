import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/domain/repositories/news_repository.dart';

class ToggleBookmark {
  final NewsRepository repository;
  ToggleBookmark(this.repository);

  Future<void> call(NewsEntity news) async {
    final isBookmarked = await repository.isBookmarked(news.url!);
    if (isBookmarked) {
      await repository.removeBookmark(news.url!);
    } else {
      await repository.addBookmark(news);
    }
  }
}
