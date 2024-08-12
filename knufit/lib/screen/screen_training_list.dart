import 'package:flutter/material.dart';
import '../../database/db_helper.dart'; // DBHelper 클래스를 import
import '../training_list.dart';

class ScreenTrainingList extends StatelessWidget {
  final Map<String, dynamic> user; // 사용자 정보를 받을 변수

  ScreenTrainingList({required this.user, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 탭의 수
      child: Scaffold(
        appBar: AppBar(
          title: Text('Training List'),
          automaticallyImplyLeading: false, // 뒤로 가기 버튼 삭제
          bottom: TabBar(
            tabs: [
              Tab(text: '전체'),
              Tab(text: '가슴'),
              Tab(text: '등'),
              Tab(text: '어깨'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildListView('전체'),
            buildListView('가슴'),
            buildListView('등'),
            buildListView('어깨'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'trainingList',
          onPressed: () {
            _showInputDialog(context);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildListView(String category) {
    List<Map<String, String>> filteredItems;
    if (category == '전체') {
      filteredItems = items;
    } else {
      filteredItems = items.where((item) => item['category'] == category).toList();
    }

    print('Filtered items for $category: ${filteredItems.length}'); // 필터링된 항목의 수를 출력

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return ListTile(
          leading: Image.asset(
            item['image']!,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          title: Text(item['title']!),
          subtitle: Text(item['subtitle']!),
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // 여기에 아이콘 버튼 클릭 시 동작할 기능을 추가하세요
            },
          ),
        );
      },
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
                    await dbHelper.createRoutineTable(user['id'], input); // 사용자 ID 포함
                    Navigator.of(context).pop();
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

