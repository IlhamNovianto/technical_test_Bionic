import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technical_test/core/constants/app_routes.dart';
import 'package:technical_test/domain/entities/chat_entities.dart';

class ChatBubble extends StatelessWidget {
  final ChatEntity message;

  const ChatBubble({super.key, required this.message});

  bool get isUser => message.sender == MessageSender.user;
  bool get _isDark => Get.isDarkMode;

  // ── Warna bubble pakai _isDark ─────────────────────────────
  Color get _bubbleColor {
    if (isUser) {
      return _isDark
          ? const Color(0xFF1565C0) // biru gelap untuk dark mode
          : const Color(0xFF1A73E8); // biru terang untuk light mode
    }
    return _isDark
        ? const Color(0xFF2C2C2C) // abu gelap untuk dark mode
        : const Color(0xFFF1F1F1); // abu terang untuk light mode
  }

  Color get _textColor {
    if (isUser) return Colors.white; // teks user selalu putih
    return _isDark
        ? const Color(0xFFE0E0E0) // teks bot terang di dark mode
        : const Color(0xFF1A1A1A); // teks bot gelap di light mode
  }

  Color get _typingBubbleColor =>
      _isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F1F1);

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) return _buildTypingBubble();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isUser ? 64 : 12,
          right: isUser ? 12 : 64,
        ),
        padding: message.type == MessageType.image
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: message.type == MessageType.image
            ? _buildImageBubble()
            : _buildTextBubble(),
      ),
    );
  }

  Widget _buildTextBubble() {
    return Text(
      message.text ?? '',
      style: TextStyle(fontSize: 14, color: _textColor, height: 1.5),
    );
  }

  Widget _buildImageBubble() {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.imagePreview, arguments: message.imagePath),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        child: Stack(
          children: [
            Image.file(
              File(message.imagePath!),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 200,
                height: 200,
                color: _isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            ),

            // Overlay icon zoom
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _typingBubbleColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: const _TypingDots(),
      ),
    );
  }
}

// ── Animasi titik tiga "bot sedang mengetik" ───────────────────
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset = ((_controller.value * 3) - i).clamp(0.0, 1.0);
            final opacity = (offset < 0.5 ? offset : 1.0 - offset) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withValues(alpha: 0.3 + opacity * 0.7),
              ),
            );
          }),
        );
      },
    );
  }
}
