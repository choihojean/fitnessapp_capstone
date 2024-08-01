import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'screen_memo.dart';

class ScreenHomeMemo extends StatefulWidget {
  final Map<String, dynamic> user;

  const ScreenHomeMemo({required this.user, Key? key}) : super(key: key);

  @override
  _ScreenHomeMemoState createState() => _ScreenHomeMemoState();
}

class _ScreenHomeMemoState extends State<ScreenHomeMemo> {
  late Future<List<Map<String, dynamic>>> _memos;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  void _loadMemos() {
    setState(() {
      _memos = DBHelper().getMemos(widget.user['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('메모 리스트'),
      // ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _memos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('저장된 메모가 없습니다.'));
          } else {
            List<Map<String, dynamic>> memos = snapshot.data!;
            return ListView.builder(
              itemCount: memos.length,
              itemBuilder: (context, index) {
                final memo = memos[index];
                return ListTile(
                  title: Text(memo['title']),
                  subtitle: Text(memo['content']),
                  onTap: () async {
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenMemo(
                          user: widget.user,
                          memo: memo,
                        ),
                      ),
                    );
                    if (result == true) _loadMemos(); // 수정 후 목록 갱신
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenMemo(user: widget.user),
            ),
          );
          if (result == true) _loadMemos(); // 추가 후 목록 갱신
        },
        child: Icon(Icons.add),
        tooltip: '새 메모 추가',
      ),
    );
  }
}
