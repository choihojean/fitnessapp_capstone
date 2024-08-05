import 'package:flutter/material.dart';

class ScreenTrainingList extends StatefulWidget {
  @override
  _ScreenTrainingListState createState() => _ScreenTrainingListState();
}

class _ScreenTrainingListState extends State<ScreenTrainingList> {
  // 기존의 아이템 리스트 (이미지와 서브타이틀 포함)
  final List<Map<String, String>> existingItems = [
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

  // 새로운 타이틀만 포함된 리스트
  final List<String> newTitles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training List'),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 삭제
      ),
      body: ListView(
        children: [
          // 기존 아이템 리스트
          ...existingItems.map((item) {
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
          }).toList(),

          // 새로운 타이틀만 포함된 리스트
          ...newTitles.asMap().entries.map((entry) {
            int index = entry.key;
            String title = entry.value;
            return ListTile(
              title: Text(title),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteTitle(index);
                },
              ),
              onTap: () {
                _onNewTitleTap(title);
              },
            );
          }).toList(),
        ],
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
                final newTitle = _controller.text;
                if (newTitle.isNotEmpty) {
                  setState(() {
                    newTitles.add(newTitle);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _onNewTitleTap(String title) {
    // 클릭 시 실행할 기능을 추가합니다.
    // 예를 들어, SnackBar를 표시할 수 있습니다.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Clicked on: $title'),
      ),
    );
  }

  void _deleteTitle(int index) {
    setState(() {
      newTitles.removeAt(index);
    });
  }
}
