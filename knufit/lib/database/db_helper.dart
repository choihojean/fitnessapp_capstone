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
        category TEXT,
        memo TEXT,
        item_order INTEGER
      )
    ''');
     await db.insert('created_tables', {'userId': userId, 'table_name': tableName}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //루틴 테이블에서 데이터 삭제
  Future<void> deleteRoutineItem(String tableName, int id) async {
  final db = await database;
  await db.delete(
    tableName,
    where: 'id = ?',
    whereArgs: [id],
  );
}
  
  // 루틴 항목의 순서를 업데이트하는 메서드
  Future<void> updateRoutineOrder(String tableName, int id, int newOrder) async {
    final db = await database;
    await db.update(
      tableName,
      {'item_order': newOrder},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRoutineMemo(String tableName, int id, String newMemo) async {
  final db = await database;
  await db.update(
    tableName,
    {'memo': newMemo},
    where: 'id = ?',
    whereArgs: [id],
  );
}

  // 특정 루틴 테이블에 데이터를 삽입하는 메소드 추가
  Future<void> insertRoutineData(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(tableName, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 특정 루틴 테이블의 데이터를 가져오는 메소드 추가
  // 데이터를 불러올 때 순서대로 불러오도록 수정
  Future<List<Map<String, dynamic>>> getRoutineTableData(int userId, String tableName) async {
    final db = await database;
    return await db.query(
      tableName,
      orderBy: 'item_order ASC',  // item_order 필드 기준으로 정렬
    );
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

  // 이메일로 사용자 조회하는 메서드 추가
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
    var user = result.first;
    
    // null 값이 포함된 필드가 있는지 확인하고 처리
    return {
      'id': user['id'],
      'email': user['email'] ?? '', // null이면 빈 문자열로 처리
      'name': user['name'] ?? '',
      'password': user['password'] ?? '',
      'profile_image': user['profile_image'] ?? '', // null 값 처리
    };
  }
  
  return null;
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert('users', {
      'email': user['email'] ?? '',
      'name': user['name'] ?? '',
      'password': hashPassword(user['password'] ?? ''), // 비밀번호는 해시화
      'profile_image': user['profile_image'] ?? '',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
      if (user['password'] != null && verifyPassword(password, user['password'])) { // 해시화된 비밀번호랑 비교
      return user;
    }
  }
    return null;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.update(
    'users',
    {
      'name': user['name'] ?? '', // null 값이면 빈 문자열 처리
      'email': user['email'] ?? '',
      'password': user['password'] ?? '',
      'profile_image': user['profile_image'] ?? '',
    },
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

  // 특정 사용자의 프로필 이미지 경로만 업데이트하는 메서드 추가
  Future<void> updateProfileImage(int userId, String imagePath) async {
    final db = await database;
    await db.update(
      'users',
      {'profile_image': imagePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // 사용자 ID로 프로필 이미지 경로를 가져오는 메서드 추가
  Future<String?> getProfileImage(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['profile_image'],
      where: 'id = ?',
      whereArgs: [userId],
    );
  
    if (result.isNotEmpty) {
      return result.first['profile_image'] as String?;
    }
    return null;
  }

  
}
