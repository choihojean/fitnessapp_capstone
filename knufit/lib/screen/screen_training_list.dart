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
        automaticallyImplyLeading: false, //뒤로 가기 버튼 삭제
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
        heroTag: 'trainingList',
        onPressed: () {
          _showInputDialog(context);
        },
        child: Icon(Icons.add),
      ),
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
              onPressed: () {
                // 입력값 처리
                String input = _controller.text;
                // 이곳에 입력값을 처리하는 로직을 추가하세요
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }
}
