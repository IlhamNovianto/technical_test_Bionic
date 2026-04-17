import 'package:get/get.dart';
import 'package:technical_test/data/database/app_database.dart';
import 'package:technical_test/data/database/dao/chat_dao.dart';
import 'package:technical_test/data/datasources/local/chat_local_datasource.dart';
import 'package:technical_test/data/datasources/remote/bot_remote_datasource.dart';
import 'package:technical_test/data/repositories/chat_repository_impl.dart';
import 'package:technical_test/domain/usecase/get_message.dart';
import 'package:technical_test/domain/usecase/send_message.dart';

import 'chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    final db = AppDatabase();

    Get.lazyPut<BotRemoteDataSource>(() => BotRemoteDataSourceImpl());
    Get.lazyPut<ChatLocalDataSource>(
      () => ChatLocalDataSourceImpl(ChatDao(db)),
    );
    Get.lazyPut(
      () => ChatRepositoryImpl(
        botDataSource: Get.find<BotRemoteDataSource>(),
        local: Get.find<ChatLocalDataSource>(),
      ),
    );
    Get.lazyPut(() => SendMessage(Get.find<ChatRepositoryImpl>()));
    Get.lazyPut(() => GetMessages(Get.find<ChatRepositoryImpl>()));
    Get.lazyPut(
      () => ChatController(
        sendMessage: Get.find<SendMessage>(),
        getMessages: Get.find<GetMessages>(),
        repository: Get.find<ChatRepositoryImpl>(),
      ),
    );
  }
}
