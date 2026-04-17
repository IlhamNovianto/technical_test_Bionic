import 'package:sqflite/sqflite.dart';

import '../../models/user_model.dart';
import '../app_database.dart';

class UserDao {
  final AppDatabase _db;
  UserDao(this._db);

  Future<void> insertOrUpdate(UserModel user) async {
    final db = await _db.database;
    await db.insert('users', {
      ...user.toMap(),
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUser(String uid) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getLastLoggedInUser() async {
    final db = await _db.database;
    final result = await db.query('users', orderBy: 'createdAt DESC', limit: 1);
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<void> deleteUser(String uid) async {
    final db = await _db.database;
    await db.delete('users', where: 'uid = ?', whereArgs: [uid]);
  }
}
