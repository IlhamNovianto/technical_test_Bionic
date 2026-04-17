import 'dart:math';

abstract class BotRemoteDataSource {
  Future<String> getBotReply(String userMessage);
}

class BotRemoteDataSourceImpl implements BotRemoteDataSource {
  // Daftar respons berdasarkan keyword
  static const Map<String, List<String>> _responses = {
    'halo': [
      'Halo! Ada yang bisa saya bantu? 😊',
      'Hai! Selamat datang, ada yang ingin kamu tanyakan?',
    ],
    'berita': [
      'Kamu bisa cek berita terkini di halaman News ya! 📰',
      'Ada banyak berita menarik hari ini, cek di tab News!',
    ],
    'cuaca': [
      'Untuk info cuaca terkini, kamu bisa cek aplikasi cuaca favoritmu! 🌤️',
      'Cuaca hari ini? Saya sarankan cek BMKG untuk info akurat!',
    ],
    'politik': [
      'Isu politik terbaru bisa kamu baca di halaman berita kami! 🗞️',
    ],
    'olahraga': [
      'Hasil pertandingan terbaru ada di halaman News kategori Sports! ⚽',
    ],
    'teknologi': [
      'Berita teknologi terkini tersedia di News Page! 💻',
      'Dunia tech berkembang pesat! Cek beritanya di halaman utama.',
    ],
    'terima kasih': [
      'Sama-sama! Senang bisa membantu 😊',
      'Dengan senang hati! Ada lagi yang ingin ditanyakan?',
    ],
    'bye': [
      'Sampai jumpa! Jangan lupa baca berita terkini ya 👋',
      'Dadah! Semoga harimu menyenangkan 🌟',
    ],
  };

  static const List<String> _defaultResponses = [
    'Maaf, saya belum paham maksudmu. Bisa dijelaskan lebih lanjut? 🤔',
    'Pertanyaan menarik! Tapi saya masih belajar. Coba tanya hal lain? 😅',
    'Hmm, saya tidak yakin dengan jawabannya. Coba cek di halaman News! 📰',
    'Saya belum punya info soal itu. Ada yang lain bisa saya bantu? 🙂',
  ];

  @override
  Future<String> getBotReply(String userMessage) async {
    await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(700)));

    final lowerMsg = userMessage.toLowerCase();

    for (final entry in _responses.entries) {
      if (lowerMsg.contains(entry.key)) {
        final replies = entry.value;
        return replies[Random().nextInt(replies.length)];
      }
    }

    return _defaultResponses[Random().nextInt(_defaultResponses.length)];
  }
}
