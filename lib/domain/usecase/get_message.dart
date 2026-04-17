import 'package:technical_test/domain/entities/chat_entities.dart';
import 'package:technical_test/domain/repositories/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;
  GetMessages(this.repository);

  Future<List<ChatEntity>> call() => repository.getLocalMessages();
}
