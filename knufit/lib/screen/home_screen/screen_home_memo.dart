import 'package:flutter/material.dart';
import 'screen_memo.dart'; // 메모 입력 화면 경로
import '../../database/db_helper.dart'; // DBHelper 경로 확인

class ScreenHomeMemo extends StatelessWidget {
  final Map<String, dynamic> user; // 로그인 정보를 받을 변수

  const ScreenHomeMemo({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper().getMemos(user['id']), // DBHelper를 통해 메모를 로드
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> memos = snapshot.data!;
            return ListView.builder(
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];
                return ListTile(
                  title: Text(memo['title']),
                  subtitle: Text(memo['content']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScreenMemo(
                                user: user,
                                memo: memo, // 수정할 메모 정보를 전달
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await DBHelper().deleteMemo(memo['id']);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('메모가 삭제되었습니다.'),
                          ));
                          // 상태를 새로 고쳐서 변경 사항 반영
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenMemo(user: user), // 새 메모 작성 화면으로 이동
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: '새 메모 추가',
      ),
    );
  }
}
