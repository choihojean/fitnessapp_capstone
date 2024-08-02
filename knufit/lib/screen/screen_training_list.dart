import 'package:flutter/material.dart';

// Define a model class for Training
class Training {
  final String title;
  final String description;
  final String imageAsset;

  Training({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}

class ScreenTrainingList extends StatelessWidget {
  // Sample list of trainings
  final List<Training> trainings = [
    Training(
      title: 'Training 1',
      description: 'Description for training 1',
      imageAsset: 'assets/test.png',
    ),
    Training(
      title: 'Training 2',
      description: 'Description for training 2',
      imageAsset: 'assets/test.png',
    ),
    Training(
      title: 'Training 3',
      description: 'Description for training 3',
      imageAsset: 'assets/test.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training List'),
      ),
      body: ListView(
        children: trainings.map((training) {
          return TrainingListTile(training: training);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the action when the + button is pressed
          // Add functionality for adding new items or navigating to another screen
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Training',
      ),
    );
  }
}

class TrainingListTile extends StatelessWidget {
  final Training training;

  TrainingListTile({required this.training});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(training.imageAsset),
      title: Text(training.title),
      subtitle: Text(training.description),
      trailing: IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          // Handle the action when the + icon is pressed
          // Add functionality such as showing a dialog or performing an action
        },
      ),
      onTap: () {
        // Handle item tap, if necessary
      },
    );
  }
}
