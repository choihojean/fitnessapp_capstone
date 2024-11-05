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

  // 테이블 데이터 삭제
  Future<Map<String, dynamic>> deleteTraining() async {
    final db = await database;
    Map<String, dynamic> result;
    try {
      await db.delete("training");
      result = {"message": "success"};
    } catch (e) {
      result = {"message": "failure", "error": e};
    } finally {
      await db.close();
    }
    return result;
  }
  
  // 테이블 데이터 추가
  Future<Map<String, dynamic>> createAndUpdateTraining(Map<String, dynamic> data) async {
    final db = await database;
    Map<String, dynamic> result;
    try {
      await db.insert("training", data, conflictAlgorithm: ConflictAlgorithm.replace);
      result = {"message": "success"};
    } catch (e) {
      result = {"message": "failure", "error": e};
    } finally {
      await db.close();
    }
    return result;
  }

  // 테이블 전체 데이터 로드
  Future<List<Map<String, dynamic>>> readTrainingAll() async {
    final db = await database;
    List<Map<String, dynamic>> result = [];
    try {
      result = await db.query(
        "training",
        orderBy: 'id ASC',
      );
    } catch (e) {
      print({"message": "failure", "error": e});
    } finally {
      await db.close();
    }
    return result;
  }

  // 테이블 전체 데이터 개수 로드
  Future<int> readTrainingAllCount() async {
    final db = await database;
    int result = 0;
    try {
      final res = await db.rawQuery('SELECT COUNT(*) FROM training');
      result = Sqflite.firstIntValue(res) ?? 0;
    } catch (e) {
      print({"message": "failure", "error": e});
    } finally {
      await db.close();
    }
    return result;
  }

  // 테이블 단일 데이터 로드
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
    } finally {
      await db.close();
    }
    return result;
  }
}
