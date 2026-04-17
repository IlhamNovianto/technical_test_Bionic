import 'package:technical_test/domain/entities/chat_entities.dart';

abstract class ChatRepository {
  Future<ChatEntity> sendTextMessage(String text);
  Future<ChatEntity> sendImageMessage(String imagePath);
  Future<ChatEntity> getBotReply(String userMessage);
  Future<List<ChatEntity>> getLocalMessages();
  Future<void> saveMessage(ChatEntity message);
}
