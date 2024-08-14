import 'package:flutter/material.dart';
import '../../database/db_helper.dart'; // DBHelper 클래스를 import

class ScreenRoutineTable extends StatelessWidget {
  final String tableName; // 클릭된 테이블 이름
  final Map<String, dynamic> user; // 사용자 정보를 받을 변수

  ScreenRoutineTable({required this.tableName, required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$tableName'),
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
                await dbHelper.deleteRoutineTable(user['id'], tableName);
                Navigator.of(context).pop(); // 삭제 후 이전 화면으로 돌아가기
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadRoutineTableData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('저장된 데이터가 없습니다.'));
          } else {
            List<Map<String, dynamic>> data = snapshot.data!;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return ListTile(
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
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadRoutineTableData() async {
    final dbHelper = DBHelper();
    return await dbHelper.getRoutineTableData(user['id'], tableName);
  }
}
