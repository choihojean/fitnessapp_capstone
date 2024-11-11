import 'package:flutter/material.dart';
import './date_memo_func.dart';

class DateMemoCreatePage extends StatefulWidget {
  final Map<String, dynamic> user;
  
  final DateTime date;

  const DateMemoCreatePage({required this.user, required this.date, Key? key}) : super(key: key);

  @override
  _DateMemoCreatePageState createState() => _DateMemoCreatePageState();
}

class _DateMemoCreatePageState extends State<DateMemoCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일 메모')
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
              onPressed: () async {
                await createDateMemo(widget.user["id"], widget.date, _titleController.text, _contentController.text);
                Navigator.pop(context, true);
              },
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
