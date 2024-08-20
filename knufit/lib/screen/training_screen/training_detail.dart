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
    String exerciseTip = exercise['tip']!;
    String exerciseDescription = exercise['description']!;
    String exercisePrecautions = exercise['precautions']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GIF 이미지 표시
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    exerciseGif,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // 제목 및 부제목
              Text(
                exerciseTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                exerciseSubtitle,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              
              // 팁 섹션
              _buildCardSection(
                title: "운동 팁",
                content: exerciseTip,
                icon: Icons.lightbulb,
              ),
              
              SizedBox(height: 16),
              
              // 설명 섹션
              _buildOrderedListSection(
                title: "운동 설명",
                items: exerciseDescription.split("\n"),  // 여러 줄을 리스트로 처리
                icon: Icons.description,
              ),
              
              SizedBox(height: 16),
              
              // 주의사항 섹션
              _buildOrderedListSection(
                title: "주의사항",
                items: exercisePrecautions.split("\n"),  // 여러 줄을 리스트로 처리
                icon: Icons.warning,
              ),
              
              SizedBox(height: 16),
              
              // 유튜브 섹션
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "유튜브에서 관련 영상 보기:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      YoutubeSearchWidget(searchQuery: exerciseTitle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 각 섹션을 카드로 빌드하는 함수
  Widget _buildCardSection({required String title, required String content, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // 리스트를 정렬하는 함수
  Widget _buildOrderedListSection({required String title, required List<String> items, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(items.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '${index + 1}. ${items[index]}',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
