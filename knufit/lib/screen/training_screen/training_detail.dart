import 'package:flutter/material.dart';
import 'youtube_search_widget.dart';


class TrainingDetail extends StatelessWidget {
  final Map<String, String> exercise;

  TrainingDetail({required this.exercise});

  @override
  Widget build(BuildContext context) {
    String exerciseTitle = exercise['title']!;
    String exerciseSubtitle = exercise['subtitle']!;
    String exerciseGif = exercise['gif']!;

    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  exerciseGif,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 16),
              Text(
                exerciseTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                exerciseSubtitle,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "유튜브에서 관련 영상 보기:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              YoutubeSearchWidget(searchQuery: exerciseTitle),
            ],
          ),
        ),
      ),
    );
  }
}
