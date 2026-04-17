import 'package:sqflite/sqflite.dart';

import '../../models/chat_model.dart';
import '../app_database.dart';

class ChatDao {
  final AppDatabase _db;
  ChatDao(this._db);

  Future<void> insertMessage(ChatModel message) async {
    final db = await _db.database;
    await db.insert(
      'chats',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMessages(List<ChatModel> messages) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final msg in messages) {
      batch.insert(
        'chats',
        msg.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ChatModel>> getAllMessages() async {
    final db = await _db.database;
    final result = await db.query('chats', orderBy: 'createdAt ASC');
    return result.map((map) => ChatModel.fromMap(map)).toList();
  }

  Future<void> deleteMessage(String id) async {
    final db = await _db.database;
    await db.delete('chats', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearChats() async {
    final db = await _db.database;
    await db.delete('chats');
  }
}
