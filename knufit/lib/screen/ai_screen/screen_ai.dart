import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScreenAI extends StatefulWidget {
  @override
  _ScreenAIState createState() => _ScreenAIState();
}

class _ScreenAIState extends State<ScreenAI> {
  final _formKey = GlobalKey<FormState>();
  String? height, weight, age, targetArea, goal;
  List<String> routines = [];

  // OpenAI API 호출 메서드
  Future<void> _sendDataToGPTAPI() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      print('API 키가 없습니다.');
      return;
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
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
            'content': '당신은 피트니스 전문가입니다.',
          },
          {
            'role': 'user',
            'content': '저는 $age살이고, 키는 $height cm이며, 몸무게는 $weight kg입니다. '
                '운동 부위는 $targetArea이며, 목표는 $goal입니다. 각 루틴에 여러 운동이 포함된 3가지 운동 루틴을 추천해 주세요.',
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final workoutRoutines = data['choices'][0]['message']['content'].split('\n\n\n');
      setState(() {
        routines = workoutRoutines;
      });
    } else {
      print('추천 실패: ${response.body}');
    }
  }

  // 폼을 통해 사용자가 입력한 정보를 받는 메서드
  void _showUserInfoInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('사용자 정보 입력'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: '키 (cm)'),
                  onChanged: (value) => height = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '몸무게 (kg)'),
                  onChanged: (value) => weight = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '나이'),
                  onChanged: (value) => age = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '운동 부위 (예: 하체, 상체)'),
                  onChanged: (value) => targetArea = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: '목표 (예: 근력 증가, 다이어트)'),
                  onChanged: (value) => goal = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendDataToGPTAPI();
              },
              child: Text('추천 받기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 운동 추천'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showUserInfoInputDialog,
            child: Text('사용자 정보 입력'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: routines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('루틴 ${index + 1}'),
                  onTap: () => _showWorkoutRoutineDetail(routines[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 루틴의 상세 내용을 다이얼로그로 표시
  void _showWorkoutRoutineDetail(String workoutRoutine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('루틴 상세 정보'),
          content: Text(workoutRoutine),
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
}
