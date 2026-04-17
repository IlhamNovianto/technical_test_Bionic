import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technical_test/presentation/chat/chat_controller.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Tombol kirim gambar
            Obx(
              () => IconButton(
                onPressed: controller.isTyping.value
                    ? null
                    : controller.sendImageMessage,
                icon: const Icon(Icons.image_outlined),
                color: const Color(0xFF1A73E8),
                tooltip: 'Kirim Gambar',
              ),
            ),

            // TextField pesan
            Expanded(
              child: TextField(
                controller: controller.textController,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => controller.sendTextMessage(),
              ),
            ),

            const SizedBox(width: 8),

            // Tombol kirim teks
            Obx(
              () => GestureDetector(
                onTap: controller.isTyping.value
                    ? null
                    : controller.sendTextMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: controller.isTyping.value
                        ? Colors.grey.shade300
                        : const Color(0xFF1A73E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
