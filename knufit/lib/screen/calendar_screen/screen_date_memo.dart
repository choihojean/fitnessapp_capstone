import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class DateMemoPage extends StatefulWidget {
  final DateTime date;

  const DateMemoPage({required this.date, Key? key}) : super(key: key);

  @override
  _DateMemoPageState createState() => _DateMemoPageState();
}

class _DateMemoPageState extends State<DateMemoPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  Map<String, dynamic>? _memo;

  @override
  void initState() {
    super.initState();
    _loadMemo();
  }

  Future<void> _loadMemo() async {
    final memos = await _dbHelper.getDateMemos(widget.date.toIso8601String().split('T')[0]);
    if (memos.isNotEmpty) {
      setState(() {
        _memo = memos.first;
        _titleController.text = _memo!['title'];
        _contentController.text = _memo!['content'];
      });
    }
  }

  Future<void> _saveMemo() async {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isNotEmpty && content.isNotEmpty) {
      if (_memo == null) {
        await _dbHelper.insertDateMemo({
          'date': widget.date.toIso8601String().split('T')[0],
          'title': title,
          'content': content,
        });
      } else {
        await _dbHelper.updateDateMemo({
          'id': _memo!['id'],
          'date': widget.date.toIso8601String().split('T')[0],
          'title': title,
          'content': content,
        });
      }
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteMemo() async {
    if (_memo != null) {
      await _dbHelper.deleteDateMemo(_memo!['id']);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일 메모'),
        actions: [
          if (_memo != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteMemo,
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
