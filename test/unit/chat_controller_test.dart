import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:technical_test/data/repositories/chat_repository_impl.dart';
import 'package:technical_test/domain/entities/chat_entities.dart';
import 'package:technical_test/domain/usecase/get_message.dart';
import 'package:technical_test/domain/usecase/send_message.dart';
import 'package:technical_test/presentation/chat/chat_controller.dart';

// ── Manual Mock ────────────────────────────────────────────────
class MockSendMessage extends Mock implements SendMessage {
  @override
  Future<ChatEntity> callText(String? text) =>
      super.noSuchMethod(
            Invocation.method(#callText, [text]),
            returnValue: Future.value(_fakeUserMsg(text ?? '')),
            returnValueForMissingStub: Future.value(_fakeUserMsg(text ?? '')),
          )
          as Future<ChatEntity>;

  @override
  Future<ChatEntity> callImage(String? imagePath) =>
      super.noSuchMethod(
            Invocation.method(#callImage, [imagePath]),
            returnValue: Future.value(_fakeImageMsg(imagePath ?? '')),
            returnValueForMissingStub: Future.value(
              _fakeImageMsg(imagePath ?? ''),
            ),
          )
          as Future<ChatEntity>;
}

class MockGetMessages extends Mock implements GetMessages {
  @override
  Future<List<ChatEntity>> call() =>
      super.noSuchMethod(
            Invocation.method(#call, []),
            returnValue: Future.value(<ChatEntity>[]),
            returnValueForMissingStub: Future.value(<ChatEntity>[]),
          )
          as Future<List<ChatEntity>>;
}

class MockChatRepositoryImpl extends Mock implements ChatRepositoryImpl {
  @override
  Future<ChatEntity> getBotReply(String? userMessage) =>
      super.noSuchMethod(
            Invocation.method(#getBotReply, [userMessage]),
            returnValue: Future.value(_fakeBotReply()),
            returnValueForMissingStub: Future.value(_fakeBotReply()),
          )
          as Future<ChatEntity>;

  @override
  Future<ChatEntity> sendTextMessage(String? text) =>
      super.noSuchMethod(
            Invocation.method(#sendTextMessage, [text]),
            returnValue: Future.value(_fakeUserMsg(text ?? '')),
            returnValueForMissingStub: Future.value(_fakeUserMsg(text ?? '')),
          )
          as Future<ChatEntity>;

  @override
  Future<ChatEntity> sendImageMessage(String? imagePath) =>
      super.noSuchMethod(
            Invocation.method(#sendImageMessage, [imagePath]),
            returnValue: Future.value(_fakeImageMsg(imagePath ?? '')),
            returnValueForMissingStub: Future.value(
              _fakeImageMsg(imagePath ?? ''),
            ),
          )
          as Future<ChatEntity>;

  @override
  Future<List<ChatEntity>> getLocalMessages() =>
      super.noSuchMethod(
            Invocation.method(#getLocalMessages, []),
            returnValue: Future.value(<ChatEntity>[]),
            returnValueForMissingStub: Future.value(<ChatEntity>[]),
          )
          as Future<List<ChatEntity>>;

  @override
  Future<void> saveMessage(ChatEntity? message) =>
      super.noSuchMethod(
            Invocation.method(#saveMessage, [message]),
            returnValue: Future.value(),
            returnValueForMissingStub: Future.value(),
          )
          as Future<void>;
}

// ── Helper data dummy ──────────────────────────────────────────
ChatEntity _fakeUserMsg(String text) => ChatEntity(
  id: 'user-${DateTime.now().millisecondsSinceEpoch}',
  text: text,
  type: MessageType.text,
  sender: MessageSender.user,
  createdAt: DateTime.now(),
);

ChatEntity _fakeImageMsg(String path) => ChatEntity(
  id: 'img-${DateTime.now().millisecondsSinceEpoch}',
  imagePath: path,
  type: MessageType.image,
  sender: MessageSender.user,
  createdAt: DateTime.now(),
);

ChatEntity _fakeBotReply() => ChatEntity(
  id: 'bot-${DateTime.now().millisecondsSinceEpoch}',
  text: 'Halo! Ada yang bisa saya bantu? 😊',
  type: MessageType.text,
  sender: MessageSender.bot,
  createdAt: DateTime.now(),
);

// ── Tests ──────────────────────────────────────────────────────
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ChatController controller;
  late MockSendMessage mockSendMessage;
  late MockGetMessages mockGetMessages;
  late MockChatRepositoryImpl mockRepo;

  setUp(() {
    mockSendMessage = MockSendMessage();
    mockGetMessages = MockGetMessages();
    mockRepo = MockChatRepositoryImpl();

    when(mockGetMessages()).thenAnswer((_) async => []);

    controller = ChatController(
      sendMessage: mockSendMessage,
      getMessages: mockGetMessages,
      repository: mockRepo,
    );

    Get.testMode = true;
  });

  tearDown(() => Get.reset());

  group('ChatController — State Awal', () {
    test('messages awalnya kosong sebelum init', () {
      expect(controller.messages, isEmpty);
    });

    test('isTyping awalnya false', () {
      expect(controller.isTyping.value, false);
    });

    test('textController awalnya kosong', () {
      expect(controller.textController.text, isEmpty);
    });
  });

  group('ChatController — Welcome Message', () {
    late ChatController controller;

    setUp(() {
      Get.reset();

      controller = Get.put(
        ChatController(
          sendMessage: mockSendMessage,
          getMessages: mockGetMessages,
          repository: mockRepo,
        ),
      );
    });

    test('welcome message muncul setelah init', () async {
      when(mockGetMessages()).thenAnswer((_) async => []);

      await controller.initChat();

      expect(controller.messages, isNotEmpty);
      expect(controller.messages.first.sender, MessageSender.bot);
    });

    test('welcome message berisi teks yang benar', () async {
      when(mockGetMessages()).thenAnswer((_) async => []);

      await controller.initChat();

      expect(controller.messages.first.text, contains('Halo!'));
    });
  });

  group('ChatController — Send Text', () {
    test('sendTextMessage kosong tidak menambah pesan', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      final countBefore = controller.messages.length;

      controller.textController.text = '';
      await controller.sendTextMessage();

      expect(controller.messages.length, countBefore);
    });

    test('sendTextMessage berhasil menambah pesan user', () async {
      when(
        mockSendMessage.callText('halo'),
      ).thenAnswer((_) async => _fakeUserMsg('halo'));
      when(
        mockRepo.getBotReply('halo'),
      ).thenAnswer((_) async => _fakeBotReply());

      controller.textController.text = 'halo';
      await controller.sendTextMessage();

      final userMsgs = controller.messages.where(
        (m) => m.sender == MessageSender.user,
      );
      expect(userMsgs, isNotEmpty);
    });

    test('textController kosong setelah pesan dikirim', () async {
      when(
        mockSendMessage.callText('test'),
      ).thenAnswer((_) async => _fakeUserMsg('test'));
      when(
        mockRepo.getBotReply('test'),
      ).thenAnswer((_) async => _fakeBotReply());

      controller.textController.text = 'test';
      await controller.sendTextMessage();

      expect(controller.textController.text, isEmpty);
    });

    test('bot membalas setelah user kirim pesan', () async {
      when(
        mockSendMessage.callText('halo'),
      ).thenAnswer((_) async => _fakeUserMsg('halo'));
      when(
        mockRepo.getBotReply('halo'),
      ).thenAnswer((_) async => _fakeBotReply());

      controller.textController.text = 'halo';
      await controller.sendTextMessage();

      final botMsgs = controller.messages.where(
        (m) => m.sender == MessageSender.bot,
      );
      expect(botMsgs, isNotEmpty);
    });
  });

  group('ChatController — Typing Indicator', () {
    test('isTyping true saat bot memproses', () async {
      when(
        mockSendMessage.callText(any),
      ).thenAnswer((_) async => _fakeUserMsg('test'));

      // 🔥 PENTING: kasih delay biar sempat true
      when(mockRepo.getBotReply(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return _fakeBotReply();
      });

      controller.textController.text = 'test';

      final future = controller.sendTextMessage();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(controller.isTyping.value, true);

      await future;
    });

    test('isTyping false setelah bot reply', () async {
      when(
        mockSendMessage.callText(any),
      ).thenAnswer((_) async => _fakeUserMsg('test'));

      when(mockRepo.getBotReply(any)).thenAnswer((_) async => _fakeBotReply());

      controller.textController.text = 'test';

      await controller.sendTextMessage();

      expect(controller.isTyping.value, false);
    });
  });
}
