import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'news_app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        uid         TEXT PRIMARY KEY,
        displayName TEXT,
        email       TEXT,
        photoUrl    TEXT,
        isGuest     INTEGER NOT NULL DEFAULT 0,
        createdAt   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE news (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        sourceName  TEXT,
        author      TEXT,
        title       TEXT NOT NULL,
        description TEXT,
        url         TEXT NOT NULL,
        urlToImage  TEXT,
        publishedAt TEXT,
        content     TEXT,
        cachedAt    TEXT NOT NULL,
        isBookmark  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE chats (
        id        TEXT PRIMARY KEY,
        text      TEXT,
        imagePath TEXT,
        type      INTEGER NOT NULL,
        sender    INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columns = await db.rawQuery('PRAGMA table_info(news)');
      final hasIsBookmark = columns.any((col) => col['name'] == 'isBookmark');

      if (!hasIsBookmark) {
        await db.execute('''
          ALTER TABLE news
          ADD COLUMN isBookmark INTEGER NOT NULL DEFAULT 0
        ''');
      }
    }
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('users');
    await db.delete('news');
    await db.delete('chats');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) await db.close();
    _database = null;
  }
}
