import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:technical_test/data/repositories/chat_repository_impl.dart';
import 'package:technical_test/domain/entities/chat_entities.dart';
import 'package:technical_test/domain/usecase/get_message.dart';
import 'package:technical_test/domain/usecase/send_message.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  final SendMessage sendMessage;
  final GetMessages getMessages;
  final ChatRepositoryImpl repository;

  ChatController({
    required this.sendMessage,
    required this.getMessages,
    required this.repository,
  });

  final messages = <ChatEntity>[].obs;
  final isTyping = false.obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
    _addWelcomeMessage();
    initChat();
  }

  Future<void> initChat() async {
    final history = await getMessages();
    messages.addAll(history);

    if (messages.isEmpty) {
      _addWelcomeMessage();
    }

    _scrollToBottom();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _loadHistory() async {
    final history = await getMessages();
    messages.addAll(history);
    _scrollToBottom();
  }

  void _addWelcomeMessage() {
    if (messages.isEmpty) {
      messages.add(
        ChatEntity(
          id: _uuid.v4(),
          text:
              'Halo! Saya asisten virtual kamu 🤖\n'
              'Kamu bisa tanya apa saja, atau kirim gambar!',
          type: MessageType.text,
          sender: MessageSender.bot,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> sendTextMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    textController.clear();

    // Tambahkan pesan user
    final userMsg = await sendMessage.callText(text);
    messages.add(userMsg);
    _scrollToBottom();

    // Tampilkan indikator "bot mengetik"
    _showTypingIndicator();

    // Ambil balasan bot
    final botReply = await repository.getBotReply(text);
    _removeTypingIndicator();
    messages.add(botReply);
    _scrollToBottom();
  }

  Future<void> sendImageMessage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    // Tambahkan pesan gambar user
    final userMsg = await sendMessage.callImage(pickedFile.path);
    messages.add(userMsg);
    _scrollToBottom();

    // Bot membalas gambar
    _showTypingIndicator();
    await Future.delayed(const Duration(milliseconds: 1200));
    _removeTypingIndicator();

    messages.add(
      ChatEntity(
        id: _uuid.v4(),
        text: 'Wah, gambar yang menarik! 📸 Ada cerita di balik foto ini?',
        type: MessageType.text,
        sender: MessageSender.bot,
        createdAt: DateTime.now(),
      ),
    );
    _scrollToBottom();
  }

  void _showTypingIndicator() {
    isTyping.value = true;
    messages.add(
      ChatEntity(
        id: 'typing',
        type: MessageType.text,
        sender: MessageSender.bot,
        createdAt: DateTime.now(),
        isLoading: true,
      ),
    );
    _scrollToBottom();
  }

  void _removeTypingIndicator() {
    isTyping.value = false;
    messages.removeWhere((m) => m.isLoading);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
