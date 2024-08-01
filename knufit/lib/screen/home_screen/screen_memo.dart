import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class ScreenMemo extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic>? memo;

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

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 내용을 모두 입력하세요.')),
      );
      return;
    }

    if (widget.memo == null) {
      await DBHelper().insertMemo({
        'userId': widget.user['id'],
        'title': title,
        'content': content,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메모가 저장되었습니다.')),
      );
    } else {
      await DBHelper().updateMemo({
        'id': widget.memo!['id'],
        'title': title,
        'content': content,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메모가 수정되었습니다.')),
      );
    }

    Navigator.pop(context, true); // 변경 사항이 생겼음을 알림
  }

  void _deleteMemo() async {
    if (widget.memo != null) {
      await DBHelper().deleteMemo(widget.memo!['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메모가 삭제되었습니다.')),
      );
      Navigator.pop(context, true); // 메모 삭제 후 변경 사항 알림
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memo == null ? '새 메모' : '메모 수정'),
        actions: [
          if (widget.memo != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteMemo,
              tooltip: '메모 삭제',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: '내용'),
                maxLines: null,
                expands: true,
              ),
            ),
            ElevatedButton(
              onPressed: _saveMemo,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
