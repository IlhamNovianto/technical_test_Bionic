import 'package:technical_test/domain/entities/chat_entities.dart';

import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);

  Future<ChatEntity> callText(String? text) =>
      repository.sendTextMessage(text ?? '');

  Future<ChatEntity> callImage(String? imagePath) =>
      repository.sendImageMessage(imagePath ?? '');
}
