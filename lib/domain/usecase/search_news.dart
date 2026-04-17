import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/domain/repositories/news_repository.dart';

class SearchNews {
  final NewsRepository repository;
  SearchNews(this.repository);

  Future<List<NewsEntity>> call(String keyword, {int page = 1}) {
    return repository.searchNews(keyword, page: page);
  }
}
