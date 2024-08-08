import 'package:flutter/material.dart';
import '../../database/db_helper.dart'; // DBHelper 클래스를 import

class ScreenRoutine extends StatefulWidget {
  final Map<String, dynamic> user;

  const ScreenRoutine({required this.user, Key? key}) : super(key: key);

  @override
  _ScreenRoutineState createState() => _ScreenRoutineState();
}

class _ScreenRoutineState extends State<ScreenRoutine> {
  List<String> tableNames = [];

  @override
  void initState() {
    super.initState();
    _loadTableNames();
  }

  Future<void> _loadTableNames() async {
    final dbHelper = DBHelper();
    final names = await dbHelper.getCreatedRoutineTables(widget.user['id']);
    setState(() {
      tableNames = names;
    });
  }

  Future<void> _deleteTable(String tableName) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteRoutineTable(widget.user['id'], tableName);
    _loadTableNames(); // 테이블 목록을 다시 로드하여 업데이트
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: tableNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tableNames[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _deleteTable(tableNames[index]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${tableNames[index]} 삭제됨')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'routine',
        onPressed: () {
          _showInputDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('루틴 이름 입력'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: '루틴 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                String input = _controller.text;
                if (input.isNotEmpty) {
                  // 입력된 이름의 유효성을 검사
                  if (_isValidTableName(input)) {
                    // DBHelper 인스턴스를 생성하여 새로운 테이블을 생성하는 메소드 호출
                    final dbHelper = DBHelper();
                    await dbHelper.createRoutineTable(widget.user['id'], input);
                    Navigator.of(context).pop();
                    _loadTableNames(); // 루틴 추가 후 목록 갱신
                  } else {
                    // 유효하지 않은 이름인 경우 스낵바 표시
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('루틴의 이름이 잘못 되었습니다')),
                    );
                  }
                }
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 테이블 이름 유효성 검사 함수
  bool _isValidTableName(String tableName) {
    // 테이블 이름이 숫자로 시작하면 안 됨
    if (RegExp(r'^[0-9]').hasMatch(tableName)) {
      return false;
    }
    // 유효한 문자만 포함해야 함 (문자, 숫자, 밑줄, 한글 등)
    if (!RegExp(r'^[a-zA-Z0-9_\uac00-\ud7a3]+$').hasMatch(tableName)) {
      return false;
    }
    return true;
  }
}
