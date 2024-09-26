import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../training_screen/training_list.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {

  List<String> _getExercisesForTargetArea(String targetArea) {
  return items
      .where((item) => item['category'] == targetArea)
      .map((item) => item['title']!) // 운동 제목만 가져오기
      .toList();
}

  Future<void> _sendDataToGPTAPI({
    required String height,
    required String weight,
    required String age,
    required String targetArea,
    required String goal,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']; // .env 파일에서 API 키 불러오기

    if (apiKey == null || apiKey.isEmpty) {
      print('API 키가 없습니다.');
      return;
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    List<String> exercisesForTargetArea = _getExercisesForTargetArea(targetArea);
    String exerciseString = exercisesForTargetArea.join(", ");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': "You are a fitness expert. Please recommend today's workout routine by choosing from the following exercises : $exerciseString",
          },
          {
            'role': 'user',
            'content': 
                '저는 $age살이고, 키는 $height cm이며, 몸무게는 $weight kg입니다. 오늘 진행할 운동 부위는 $targetArea이며, 목표는 $goal입니다. 적절한 운동 루틴을 3개 추천해주세요.',
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 받는 데이터 구조에 따라 처리 - 예시로 \n\n 으로 나누었습니다.
      final workoutRoutines = data['choices'][0]['message']['content'].split('\n\n'); 
      _showWorkoutRoutineList(workoutRoutines); // 받은 루틴들을 리스트로 표시
    } else {
      // 오류 처리
      print('추천 실패: ${response.body}');
    }
  }

  void _showWorkoutRoutineList(List<String> workoutRoutines) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('추천된 운동 루틴들'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: workoutRoutines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('루틴 ${index + 1}'),
                  onTap: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    _showWorkoutRoutineDetail(workoutRoutines[index]); // 선택한 루틴의 상세 정보 표시
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _showWorkoutRoutineDetail(String workoutRoutine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('루틴 상세 정보'),
          content: Text(workoutRoutine), // 선택된 운동 루틴의 상세 정보를 표시
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI 운동 추천")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _sendDataToGPTAPI(
              height: '173',
              weight: '63',
              age: '25',
              targetArea: '어깨',
              goal: '근력 강화',
            );
          },
          child: Text('운동 루틴 받기'),
        ),
      ),
    );
  }
}
