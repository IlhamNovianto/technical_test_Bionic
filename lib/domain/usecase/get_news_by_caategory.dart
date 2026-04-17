import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/domain/repositories/news_repository.dart';

class GetNewsByCategory {
  final NewsRepository repository;
  GetNewsByCategory(this.repository);

  Future<List<NewsEntity>> call(String category, {int page = 1}) {
    return repository.getNewsByCategory(category, page: page);
  }
}
