import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import '../utils/utils.dart'; // hashPassword, verifyPassword 함수가 포함된 파일

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
      version: 1, // userId 추가된 created_tables 테이블
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE training (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            name TEXT,
            target TEXT,
            tip TEXT,
            preparation TEXT,
            movement TEXT,
            breathing TEXT,
            precautions TEXT,
            img TEXT,
            gif TEXT
          )
        ''');
      }
    );
  }

/*
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
*/

  // 테이블 데이터 create => (데이터 리턴)
  Future<bool> createTraining(List<Map<String, dynamic>> dataList) async {
    final db = await database;
    bool result = false;
    try {
      await Future.forEach(dataList,
        (data) async {
          await db.insert("training", data, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      );
      result = true;
    } catch (e) {
      result = false;
    }
    return result;
  }

  // 테이블 전체 데이터 read => (데이터, null 리턴)
  Future<List<Map<String, dynamic>>> readTrainingAll() async {
    final db = await database;
    List<Map<String, dynamic>> result = [];
    try {
      result = await db.query(
        "training",
        orderBy: 'id ASC',
      );
    } catch (e) {
      print('error: $e');
    }
    return result;
  }


  // 테이블 전체 데이터 개수 read => (int 리턴)
  Future<int> readTrainingAllCount() async {
    final db = await database;
    int result = 0;
    try {
      final res = await db.rawQuery('SELECT COUNT(*) FROM training');
      result = Sqflite.firstIntValue(res) ?? 0;
    } catch (e) {
      print({"message": "failure", "error": e});
    }
    return result;
  }

  // 특정 카테고리에 맞는 운동 데이터를 가져오는 메서드
  Future<List<Map<String, dynamic>>> getTrainingByCategory(String category) async {
    final db = await database;
    List<Map<String, dynamic>> result = [];
    try {
      result = await db.query(
        "training",
        where: "category = ?",
        whereArgs: [category],
        orderBy: 'id ASC',
      );
    } catch (e) {
      print('error: $e');
    }
    return result;
  }

  // 테이블 단일 데이터 read => (데이터 리턴)
  Future<Map<String, dynamic>> readTraining(int trainingId) async {
    final db = await database;
    Map<String, dynamic>? result;
    try {
      final res = await db.query(
       "training",
        where: "id = ?",
        whereArgs: [trainingId],
        orderBy: 'id ASC',
        limit: 1
      );
      result = res.isNotEmpty ? res.first : {"message": "failure"};
    } catch (e) {
      result = {"message": "failure", "error": e};
    }
    return result;
  }

  // 테이블 데이터 update => (성공, 실패 여부 리턴)
  Future<bool> updateTraining(Map<String, dynamic> data) async {
    final db = await database;
    bool result;
    try {
      await db.update("training", data, conflictAlgorithm: ConflictAlgorithm.replace);
      result = true;
    } catch (e) {
      print('error: $e');
      result = false;
    }
    return result;
  }

  // 테이블 데이터 delete => (성공, 실패 여부 리턴)
  Future<bool> deleteTraining() async {
    final db = await database;
    bool result = false;
    try {
      await db.delete("training");
      result = true;
    } catch (e) {
      print('error: $e');
      result = false;
    }
    return result;
  }
}
