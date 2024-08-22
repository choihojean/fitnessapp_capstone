import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'screen_routine_table.dart';

class ScreenRoutine extends StatefulWidget {
  final Map<String, dynamic> user;

  const ScreenRoutine({required this.user, Key? key}) : super(key: key);

  @override
  _ScreenRoutineState createState() => _ScreenRoutineState();
}

class _ScreenRoutineState extends State<ScreenRoutine> {
  List<String> tableNames = [];
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadTableNames();
  }

  Future<void> _loadTableNames() async {
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
            onTap: () async {
              // ScreenRoutineTable로 이동 시 변경 사항 반영
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenRoutineTable(
                    tableName: tableNames[index],
                    user: widget.user,
                  ),
                ),
              );

              if (result == true) {
                _loadTableNames(); // 루틴 목록 갱신
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showInputDialog(context);
          _loadTableNames(); // 루틴 목록 갱신
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showInputDialog(BuildContext context) async {
    final TextEditingController _controller = TextEditingController();

    await showDialog(
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
                  if (_isValidTableName(input)) {
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

  bool _isValidTableName(String tableName) {
    if (RegExp(r'^[0-9]').hasMatch(tableName)) {
      return false;
    }
    if (!RegExp(r'^[a-zA-Z0-9_\uac00-\ud7a3]+$').hasMatch(tableName)) {
      return false;
    }
    return true;
  }
}
