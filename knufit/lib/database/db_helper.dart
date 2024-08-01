import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/utils.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 2, //이미지 선택을 추가하기 위해서 버전 올렸습니다.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT,
            name TEXT,
            password TEXT
            profile_image TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE memos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            title TEXT,
            content TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT');
        }
      },
    );
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    user['password'] = hashPassword(user['password']); // 비밀번호 해시화
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      var user = maps.first;
      if (verifyPassword(password, user['password'])) {
        return user;
      }
    }
    return null;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<void> insertMemo(Map<String, dynamic> memo) async {
    final db = await database;
    await db.insert('memos', memo, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getMemos(int userId) async {
    final db = await database;
    return await db.query(
      'memos',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateMemo(Map<String, dynamic> memo) async {
    final db = await database;
    await db.update(
      'memos',
      memo,
      where: 'id = ?',
      whereArgs: [memo['id']],
    );
  }

  Future<void> deleteMemo(int id) async {
    final db = await database;
    await db.delete(
      'memos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
