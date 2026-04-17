import 'package:technical_test/data/database/dao/chat_dao.dart';
import 'package:technical_test/data/models/chat_model.dart';

abstract class ChatLocalDataSource {
  Future<void> saveMessage(ChatModel message);
  Future<List<ChatModel>> getAllMessages();
  Future<void> clearChats();
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  final ChatDao _chatDao;
  ChatLocalDataSourceImpl(this._chatDao);

  @override
  Future<void> saveMessage(ChatModel message) =>
      _chatDao.insertMessage(message);

  @override
  Future<List<ChatModel>> getAllMessages() => _chatDao.getAllMessages();

  @override
  Future<void> clearChats() => _chatDao.clearChats();
}
