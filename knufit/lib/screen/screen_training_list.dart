import 'package:flutter/material.dart';

class ScreenTrainingList extends StatelessWidget {
  final List<Map<String, String>> items = [
    {
      'title': 'Training 1',
      'subtitle': 'Subtitle 1',
      'image': 'assets/test.png',
    },
    {
      'title': 'Training 2',
      'subtitle': 'Subtitle 2',
      'image': 'assets/test.png',
    },
    {
      'title': 'Training 3',
      'subtitle': 'Subtitle 3',
      'image': 'assets/test.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training List'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Image.asset(
              item['image']!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showInputDialog(context);
        },
        child: Icon(Icons.add)
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    final TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('새 루틴 추가'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "루틴의 이름을 입력해주세요"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () {
                // 나중에 입력값을 처리할 기능을 추가
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
