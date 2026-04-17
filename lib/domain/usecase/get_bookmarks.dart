import 'package:technical_test/domain/entities/news_entities.dart';
import 'package:technical_test/domain/repositories/news_repository.dart';

class GetBookmarks {
  final NewsRepository repository;
  GetBookmarks(this.repository);

  Future<List<NewsEntity>> call() {
    return repository.getBookmarks();
  }
}
