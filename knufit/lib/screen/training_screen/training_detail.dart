// training_detail.dart

import 'package:flutter/material.dart';
import 'youtube_search_widget.dart';

class TrainingDetail extends StatelessWidget {
  final Map<String, dynamic> exercise;

  TrainingDetail({required this.exercise});

  @override
  Widget build(BuildContext context) {
    // 운동의 기본 정보를 받음
    String exerciseTitle = exercise['name'] ?? '운동 이름';
    String exerciseSubtitle = exercise['target'] ?? '타겟 부위';
    String exerciseGif = exercise['gif'] ?? '';
    String exerciseTip = exercise['tip'] ?? '';
    String exercisePreparation = exercise['preparation'] ?? '';
    String exerciseMovement = exercise['movement'] ?? '';
    String exerciseBreathing = exercise['breathing'] ?? '';
    String exercisePrecautions = exercise['precautions'] ?? '';

    // 준비, 움직임 부분을 리스트로 나누기
    List<String> preparationSteps = exercisePreparation.split("\n");
    List<String> movementSteps = exerciseMovement.split("\n");

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
                  child: Image.network( // Image.asset에서 Image.network로 변경
                    exerciseGif,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 200, color: Colors.grey);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
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

              // 운동 설명 섹션 (준비, 움직임, 호흡법)
              _buildExerciseDetailsSection(
                preparation: preparationSteps,
                movement: movementSteps,
                breathing: exerciseBreathing,
              ),
              SizedBox(height: 16),

              // 주의사항 섹션
              _buildOrderedListSection(
                title: "주의사항",
                items: exercisePrecautions.split("\n"), // 주의사항을 리스트로 처리
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

  // 운동 팁과 같은 단순한 텍스트 섹션을 카드로 빌드하는 함수
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  // 운동 설명을 세 가지 파트로 나누는 함수 (준비, 움직임, 호흡법)
  Widget _buildExerciseDetailsSection({
    required List<String> preparation,
    required List<String> movement,
    required String breathing,
  }) {
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
                Icon(Icons.description, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  "운동 설명",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),

            // 준비 섹션
            _buildSectionTitle("준비"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(preparation.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '${index + 1}. ${preparation[index]}',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }),
            ),
            SizedBox(height: 16),

            // 움직임 섹션
            _buildSectionTitle("움직임"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(movement.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '${index + 1}. ${movement[index]}',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }),
            ),
            SizedBox(height: 16),

            // 호흡법 섹션
            _buildSectionTitle("호흡법"),
            Text(breathing, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // 작은 섹션 제목 스타일링 함수
  Widget _buildSectionTitle(String title) {
    return Text(
      '- $title',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // 주의사항과 같은 리스트를 정렬하는 함수
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

// import 'package:flutter/material.dart';
// import 'youtube_search_widget.dart';

// class TrainingDetail extends StatelessWidget {
//   final Map<String, dynamic> exercise;

//   TrainingDetail({required this.exercise});

//   @override
//   Widget build(BuildContext context) {
//     // 운동의 기본 정보를 받음
//     String exerciseTitle = exercise['name'] ?? '운동 이름';
//     String exerciseSubtitle = exercise['target'] ?? '타겟 부위';
//     String exerciseGif = exercise['gif'] ?? '';
//     String exerciseTip = exercise['tip'] ?? '';
//     String exercisePreparation = exercise['preparation'] ?? '';
//     String exerciseMovement = exercise['movement'] ?? '';
//     String exerciseBreathing = exercise['breathing'] ?? '';
//     String exercisePrecautions = exercise['precautions'] ?? '';

//     // 준비, 움직임 부분을 리스트로 나누기
//     List<String> preparationSteps = exercisePreparation.split("\n");
//     List<String> movementSteps = exerciseMovement.split("\n");

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(exerciseTitle),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // GIF 이미지 표시
//               Center(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.network( // Image.asset에서 Image.network로 변경
//                     exerciseGif,
//                     height: 200,
//                     fit: BoxFit.contain,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Icon(Icons.broken_image, size: 200, color: Colors.grey);
//                     },
//                     loadingBuilder: (context, child, loadingProgress) {
//                       if (loadingProgress == null) return child;
//                       return Center(child: CircularProgressIndicator());
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),

//               // 제목 및 부제목
//               Text(
//                 exerciseTitle,
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 exerciseSubtitle,
//                 style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//               ),
//               SizedBox(height: 16),

//               // 팁 섹션
//               _buildCardSection(
//                 title: "운동 팁",
//                 content: exerciseTip,
//                 icon: Icons.lightbulb,
//               ),
//               SizedBox(height: 16),

//               // 운동 설명 섹션 (준비, 움직임, 호흡법)
//               _buildExerciseDetailsSection(
//                 preparation: preparationSteps,
//                 movement: movementSteps,
//                 breathing: exerciseBreathing,
//               ),
//               SizedBox(height: 16),

//               // 주의사항 섹션
//               _buildOrderedListSection(
//                 title: "주의사항",
//                 items: exercisePrecautions.split("\n"), // 주의사항을 리스트로 처리
//                 icon: Icons.warning,
//               ),

//               SizedBox(height: 16),

//               // 유튜브 섹션
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "유튜브에서 관련 영상 보기:",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       YoutubeSearchWidget(searchQuery: exerciseTitle),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // 운동 팁과 같은 단순한 텍스트 섹션을 카드로 빌드하는 함수
//   Widget _buildCardSection({required String title, required String content, required IconData icon}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: Colors.orange),
//                 SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               content,
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 운동 설명을 세 가지 파트로 나누는 함수 (준비, 움직임, 호흡법)
//   Widget _buildExerciseDetailsSection({
//     required List<String> preparation,
//     required List<String> movement,
//     required String breathing,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.description, color: Colors.orange),
//                 SizedBox(width: 8),
//                 Text(
//                   "운동 설명",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),

//             // 준비 섹션
//             _buildSectionTitle("준비"),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: List.generate(preparation.length, (index) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Text(
//                     '${index + 1}. ${preparation[index]}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 );
//               }),
//             ),
//             SizedBox(height: 16),

//             // 움직임 섹션
//             _buildSectionTitle("움직임"),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: List.generate(movement.length, (index) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Text(
//                     '${index + 1}. ${movement[index]}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 );
//               }),
//             ),
//             SizedBox(height: 16),

//             // 호흡법 섹션
//             _buildSectionTitle("호흡법"),
//             Text(breathing, style: TextStyle(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }

//   // 작은 섹션 제목 스타일링 함수
//   Widget _buildSectionTitle(String title) {
//     return Text(
//       '- $title',
//       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//     );
//   }

//   // 주의사항과 같은 리스트를 정렬하는 함수
//   Widget _buildOrderedListSection({required String title, required List<String> items, required IconData icon}) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: Colors.orange),
//                 SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: List.generate(items.length, (index) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Text(
//                     '${index + 1}. ${items[index]}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
