import 'package:flutter/material.dart';
import 'screen_routine_table.dart'; // 새로 만든 파일 import
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: tableNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tableNames[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenRoutineTable(
                    tableName: tableNames[index],
                    user: widget.user,
                  ),
                ),
              );
            },
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
                    final dbHelper = DBHelper();

                    // 이미 존재하는 테이블 이름인지 확인
                    bool exists = await dbHelper.routineTableExists(widget.user['id'], input);
                    if (exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('이미 존재하는 루틴 이름입니다')),
                      );
                    } else {
                      await dbHelper.createRoutineTable(widget.user['id'], input);
                      Navigator.of(context).pop();
                      _loadTableNames(); // 루틴 추가 후 목록 갱신
                    }
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
