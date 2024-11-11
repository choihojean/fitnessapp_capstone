import 'package:flutter/material.dart';
import './date_memo_func.dart';

class DateMemoEditPage extends StatefulWidget {
  final Map<String, dynamic> datememo;

  const DateMemoEditPage({required this.datememo, Key? key}) : super(key: key);

  @override
  _DateMemoEditPageState createState() => _DateMemoEditPageState();
}

class _DateMemoEditPageState extends State<DateMemoEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late DateTime date;

  void typeStringToDate() {
    date = DateTime.parse(widget.datememo["datetime"]);
    _titleController.text = widget.datememo["title"];
    _contentController.text = widget.datememo["content"];
  }

  @override
  void initState() {
    super.initState();
    typeStringToDate();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${date.year}년 ${date.month}월 ${date.day}일 메모'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await deleteDateMemo(widget.datememo["id"], widget.datememo["user_id"]);
              Navigator.pop(context, true);
            },
          )
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
              onPressed: () async {
                await updateDateMemo(widget.datememo, _titleController.text, _contentController.text);
                Navigator.pop(context, true);
              },
              child: Text('수정'),
            ),
          ],
        ),
      ),
    );
  }
}
