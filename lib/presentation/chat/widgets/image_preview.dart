import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePreviewPage extends StatelessWidget {
  const ImagePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String imagePath = Get.arguments as String;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Tombol download/share
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showOptions(context, imagePath),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          // Bisa zoom in/out
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.white54, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Gambar tidak dapat ditampilkan',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, String imagePath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Simpan ke galeri
            ListTile(
              leading: const Icon(Icons.download_outlined, color: Colors.white),
              title: const Text(
                'Simpan ke Galeri',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Info',
                  'Fitur simpan belum tersedia',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.grey.shade800,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                );
              },
            ),

            // Bagikan
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Colors.white),
              title: const Text(
                'Bagikan',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                Get.snackbar(
                  'Info',
                  'Fitur bagikan belum tersedia',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.grey.shade800,
                  colorText: Colors.white,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
