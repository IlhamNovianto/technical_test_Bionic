import 'package:technical_test/data/datasources/local/chat_local_datasource.dart';
import 'package:technical_test/data/datasources/remote/bot_remote_datasource.dart';
import 'package:technical_test/data/models/chat_model.dart';
import 'package:technical_test/domain/entities/chat_entities.dart';
import 'package:technical_test/domain/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  final BotRemoteDataSource _botDataSource;
  final ChatLocalDataSource _local;
  final _uuid = const Uuid();

  ChatRepositoryImpl({
    required BotRemoteDataSource botDataSource,
    required ChatLocalDataSource local,
  }) : _botDataSource = botDataSource,
       _local = local;

  @override
  Future<ChatEntity> sendTextMessage(String text) async {
    final message = ChatModel(
      id: _uuid.v4(),
      text: text,
      type: MessageType.text,
      sender: MessageSender.user,
      createdAt: DateTime.now(),
    );
    await _local.saveMessage(message); // simpan ke SQLite
    return message;
  }

  @override
  Future<ChatEntity> sendImageMessage(String imagePath) async {
    final message = ChatModel(
      id: _uuid.v4(),
      imagePath: imagePath,
      type: MessageType.image,
      sender: MessageSender.user,
      createdAt: DateTime.now(),
    );
    await _local.saveMessage(message); // simpan ke SQLite
    return message;
  }

  @override
  Future<ChatEntity> getBotReply(String userMessage) async {
    final replyText = await _botDataSource.getBotReply(userMessage);
    final reply = ChatModel(
      id: _uuid.v4(),
      text: replyText,
      type: MessageType.text,
      sender: MessageSender.bot,
      createdAt: DateTime.now(),
    );
    await _local.saveMessage(reply); // simpan ke SQLite
    return reply;
  }

  @override
  Future<List<ChatEntity>> getLocalMessages() async {
    // Load riwayat chat dari SQLite
    return await _local.getAllMessages();
  }

  @override
  Future<void> saveMessage(ChatEntity message) async {
    final model = ChatModel.fromEntity(message);
    await _local.saveMessage(model);
  }
}
