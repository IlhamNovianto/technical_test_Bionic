import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_bar.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF1A73E8).withValues(alpha: 0.1),
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 20,
                color: Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asisten Virtual',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Obx(
                  () => Text(
                    controller.isTyping.value ? 'sedang mengetik...' : 'online',
                    style: TextStyle(
                      fontSize: 11,
                      color: controller.isTyping.value
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Daftar pesan
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(message: controller.messages[index]);
                },
              ),
            ),
          ),

          // Input bar
          const ChatInputBar(),
        ],
      ),
    );
  }
}
