import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/domain/repositories/news_repository.dart';

class GetTopHeadlines {
  final NewsRepository repository;
  GetTopHeadlines(this.repository);

  // Latest news (tab "Latest")
  Future<List<NewsEntity>> call({int page = 1}) {
    return repository.getLatestNews(page: page);
  }
}
