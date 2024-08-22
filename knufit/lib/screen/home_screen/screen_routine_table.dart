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
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadRoutineTableData();
  }

  Future<void> _loadRoutineTableData() async {
    final loadedData = await dbHelper.getRoutineTableData(widget.user['id'], widget.tableName);
    setState(() {
      // 각 Map 객체를 수정 가능하도록 복사
      data = List<Map<String, dynamic>>.from(loadedData.map((item) => Map<String, dynamic>.from(item)));
    });
  }

  Future<void> _updateMemo(int index, String newMemo) async {
    setState(() {
      data[index]['memo'] = newMemo;
    });

    // 데이터베이스에 메모 업데이트
    await dbHelper.updateRoutineMemo(widget.tableName, data[index]['id'], newMemo);
  }

  Future<void> _updateOrder() async {
    for (int i = 0; i < data.length; i++) {
      await dbHelper.updateRoutineOrder(widget.tableName, data[i]['id'], i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tableName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              // 메모 수정 및 저장 로직
              for (int i = 0; i < data.length; i++) {
                await _updateMemo(i, data[i]['memo']);
              }
              await _updateOrder();  // 변경된 순서 저장
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('변경된 메모와 순서가 저장되었습니다.')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
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
                await dbHelper.deleteRoutineTable(
                    widget.user['id'], widget.tableName);
                Navigator.of(context).pop(true); // 삭제 후 true 반환
              }
            },
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: data.length,
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = data.removeAt(oldIndex);
            data.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final item = data[index];
          final TextEditingController memoController = TextEditingController(text: item['memo']);

          return Column(
            key: ValueKey(item['id']),
            children: [
              ListTile(
                leading: Image.asset(
                  item['image']!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
                title: Text(item['title']!),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['content']!,
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.9), // subtitle의 투명도 설정
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: memoController,
                      decoration: InputDecoration(
                        hintText: '메모를 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (newValue) {
                        data[index]['memo'] = newValue;
                      },
                    ),
                  ],
                ),
              ),
              Divider(), // 항목 간의 구분선을 추가
            ],
          );
        },
      ),
    );
  }
}
