import 'package:flutter/material.dart';
import '../../database/db_helper.dart'; // DBHelper 클래스를 import

class ScreenRoutineTable extends StatefulWidget {
  final String tableName; // 클릭된 테이블 이름
  final Map<String, dynamic> user; // 사용자 정보를 받을 변수

  ScreenRoutineTable({required this.tableName, required this.user, Key? key}) : super(key: key);

  @override
  _ScreenRoutineTableState createState() => _ScreenRoutineTableState();
}

class _ScreenRoutineTableState extends State<ScreenRoutineTable> {
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    _loadRoutineTableData();
  }

  Future<void> _loadRoutineTableData() async {
    final dbHelper = DBHelper();
    final loadedData = await dbHelper.getRoutineTableData(widget.user['id'], widget.tableName);
    setState(() {
      data = loadedData;
    });
  }

  void _addRoutine(String title, String content) {
    final newRoutine = {
      'title': title,
      'content': content,
      'image': 'assets/default_image.png', // 기본 이미지 경로 설정
    };
    setState(() {
      data.add(newRoutine);
    });
    // 데이터베이스에 추가하는 로직을 여기에 구현 가능
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tableName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // 삭제 확인 다이얼로그
              bool? confirmed = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('루틴 삭제'),
                    content: Text('이 루틴을 정말 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('삭제'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                final dbHelper = DBHelper();
                await dbHelper.deleteRoutineTable(widget.user['id'], widget.tableName);
                Navigator.of(context).pop(); // 삭제 후 이전 화면으로 돌아가기
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          final TextEditingController _textController = TextEditingController();

          return Column(
            children: [
              ListTile(
                leading: Image.asset(
                  item['image']!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
                title: Text(item['title']!),
                subtitle: Text(
                  item['content']!,
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.9), // subtitle의 투명도 설정
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: '추가할 내용을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addRoutine(item['title']!, value);
                      _textController.clear();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
