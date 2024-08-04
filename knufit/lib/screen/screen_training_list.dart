import 'package:flutter/material.dart';

class TrainingItem {
  final String image;
  final String title;
  final String subtitle;

  TrainingItem({required this.image, required this.title, required this.subtitle});
}

class ScreenTrainingList extends StatelessWidget {
  final List<TrainingItem> trainingItems = [
    TrainingItem(image: 'assets/test.png', title: 'Training 1', subtitle: 'Subtitle 1'),
    TrainingItem(image: 'assets/test.png', title: 'Training 2', subtitle: 'Subtitle 2'),
    TrainingItem(image: 'assets/test.png', title: 'Training 3', subtitle: 'Subtitle 3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training List'),
      ),
      body: ListView.builder(
        itemCount: trainingItems.length,
        itemBuilder: (context, index) {
          final item = trainingItems[index];
          return ListTile(
            leading: Image.asset(item.image, width: 50, height: 50),
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // 기능 추가 예정
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 기능 추가 예정
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
