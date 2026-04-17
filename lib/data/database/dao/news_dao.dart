import 'package:sqflite/sqflite.dart';
import 'package:technical_test/data/database/app_database.dart';
import 'package:technical_test/data/models/news_model.dart';

class NewsDao {
  final AppDatabase _db;
  NewsDao(this._db);

  Future<void> cacheNews(List<NewsModel> newsList) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final news in newsList) {
      batch.insert('news', {
        ...news.toMap(),
        'cachedAt': DateTime.now().toIso8601String(),
        'isBookmark': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<NewsModel>> getCachedNews() async {
    final db = await _db.database;
    final result = await db.query(
      'news',
      where: 'isBookmark = ?',
      whereArgs: [0],
      orderBy: 'cachedAt DESC',
    );
    return result.map((m) => NewsModel.fromMap(m)).toList();
  }

  Future<bool> isCacheValid() async {
    final db = await _db.database;
    final result = await db.query(
      'news',
      where: 'isBookmark = ?',
      whereArgs: [0],
      orderBy: 'cachedAt DESC',
      limit: 1,
    );
    if (result.isEmpty) return false;
    final cachedAt = DateTime.parse(result.first['cachedAt'] as String);
    return DateTime.now().difference(cachedAt).inHours < 1;
  }

  Future<void> clearNews() async {
    final db = await _db.database;
    await db.delete('news', where: 'isBookmark = ?', whereArgs: [0]);
  }

  Future<void> addBookmark(NewsModel news) async {
    final db = await _db.database;
    await db.insert('news', {
      ...news.toMap(),
      'cachedAt': DateTime.now().toIso8601String(),
      'isBookmark': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeBookmark(String url) async {
    final db = await _db.database;
    await db.delete(
      'news',
      where: 'url = ? AND isBookmark = ?',
      whereArgs: [url, 1],
    );
  }

  Future<List<NewsModel>> getBookmarks() async {
    final db = await _db.database;
    final result = await db.query(
      'news',
      where: 'isBookmark = ?',
      whereArgs: [1],
      orderBy: 'cachedAt DESC',
    );
    return result.map((m) => NewsModel.fromMap(m)).toList();
  }

  Future<bool> isBookmarked(String url) async {
    final db = await _db.database;
    final result = await db.query(
      'news',
      where: 'url = ? AND isBookmark = ?',
      whereArgs: [url, 1],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
