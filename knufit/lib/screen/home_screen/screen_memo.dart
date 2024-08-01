import 'package:flutter/material.dart';
import '../../database/db_helper.dart'; // DBHelper 경로 확인

class ScreenMemo extends StatefulWidget {
  final Map<String, dynamic> user; // 로그인 정보를 받을 변수
  final Map<String, dynamic>? memo; // 수정할 메모 정보

  const ScreenMemo({required this.user, this.memo, Key? key}) : super(key: key);

  @override
  _ScreenMemoState createState() => _ScreenMemoState();
}

class _ScreenMemoState extends State<ScreenMemo> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.memo != null) {
      _titleController.text = widget.memo!['title'];
      _contentController.text = widget.memo!['content'];
    }
  }

  void _saveMemo() async {
    String title = _titleController.text;
    String content = _contentController.text;
    int userId = widget.user['id'];

    if (title.isNotEmpty && content.isNotEmpty) {
      if (widget.memo != null) {
        // 메모 수정
        await DBHelper().updateMemo({
          'id': widget.memo!['id'],
          'userId': userId,
          'title': title,
          'content': content,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('메모가 수정되었습니다.'),
        ));
      } else {
        // 새로운 메모 저장
        await DBHelper().insertMemo({
          'userId': userId,
          'title': title,
          'content': content,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('메모가 저장되었습니다.'),
        ));
      }
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('제목과 내용을 입력하세요.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memo != null ? '메모 수정' : '새 메모'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMemo,
              child: Text(widget.memo != null ? '저장' : '저장'),
            ),
          ],
        ),
      ),
    );
  }
}
