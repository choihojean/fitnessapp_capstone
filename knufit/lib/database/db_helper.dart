import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/utils.dart'; // hashPassword, verifyPassword 함수가 포함된 파일

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
      version: 5, // userId 추가된 created_tables 테이블
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT,
            name TEXT,
            password TEXT,
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
        await db.execute('''
          CREATE TABLE date_memos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            title TEXT,
            content TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE created_tables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            table_name TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE date_memos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT,
              title TEXT,
              content TEXT
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE created_tables (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              table_name TEXT
            )
          ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
            ALTER TABLE created_tables ADD COLUMN userId INTEGER
          ''');
        }
      },
    );
  }

  // 루틴 테이블을 생성하기 전에 동일한 이름의 테이블이 존재하는지 확인하는 메소드
  Future<bool> routineTableExists(int userId, String tableName) async {
    final db = await database;
    final result = await db.query(
      'created_tables',
      where: 'userId = ? AND table_name = ?',
      whereArgs: [userId, tableName],
    );
    return result.isNotEmpty;
  }

  // 새로운 루틴 테이블을 생성하는 메소드
  Future<void> createRoutineTable(int userId, String tableName) async {
    final db = await database;

    // 동일한 이름의 테이블이 있는지 확인
    bool exists = await routineTableExists(userId, tableName);
    if (exists) {
      throw Exception('The routine table with the same name already exists.');
    }

    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        image TEXT,
        category TEXT
      )
    ''');
    await db.insert('created_tables', {'userId': userId, 'table_name': tableName}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 특정 루틴 테이블에 데이터를 삽입하는 메소드 추가
  Future<void> insertRoutineData(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(tableName, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 특정 루틴 테이블의 데이터를 가져오는 메소드 추가
  Future<List<Map<String, dynamic>>> getRoutineTableData(int userId, String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }

  // 생성된 루틴 테이블 목록을 가져오는 메소드
  Future<List<String>> getCreatedRoutineTables(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> tables = await db.query(
      'created_tables',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return tables.map((table) => table['table_name'] as String).toList();
  }

  // 특정 루틴 테이블을 삭제하는 메소드
  Future<void> deleteRoutineTable(int userId, String tableName) async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
    await db.delete(
      'created_tables',
      where: 'userId = ? AND table_name = ?',
      whereArgs: [userId, tableName],
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

  Future<void> insertDateMemo(Map<String, dynamic> dateMemo) async {
    final db = await database;
    await db.insert('date_memos', dateMemo, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getDateMemos(String date) async {
    final db = await database;
    return await db.query(
      'date_memos',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<List<Map<String, dynamic>>> getAllMemos() async {
    final db = await database;
    return await db.query('date_memos');
  }

  Future<void> updateDateMemo(Map<String, dynamic> dateMemo) async {
    final db = await database;
    await db.update(
      'date_memos',
      dateMemo,
      where: 'id = ?',
      whereArgs: [dateMemo['id']],
    );
  }

  Future<void> deleteDateMemo(int id) async {
    final db = await database;
    await db.delete(
      'date_memos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
