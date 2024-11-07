/*
// DB에서 onCreate는 한 번만 가능 = db_helper에서 통합으로 실행해야함 = db_training 지금은 못씀
// DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해DB 빨리 변경해
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBTraining {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // 테이블 생성
  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db,version) async {
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
*/