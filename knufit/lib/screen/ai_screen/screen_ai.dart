import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../training_screen/training_list.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String? height, weight, age, targetArea, goal;
  List<List<String>> routines = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRoutines();
  }

  // SharedPreferences에서 저장된 루틴을 불러오는 메서드
  Future<void> _loadSavedRoutines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedRoutines = prefs.getStringList('saved_routines');
    if (savedRoutines != null) {
      setState(() {
        routines = savedRoutines.map((routine) => routine.split(', ')).toList();
      });
    }
  }

  // 추천받은 루틴을 SharedPreferences에 저장하는 메서드
  Future<void> _saveRoutinesToPrefs(List<List<String>> routines) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> routinesAsString = routines.map((routine) => routine.join(', ')).toList();
    await prefs.setStringList('saved_routines', routinesAsString);
  }

  // 타겟 부위에 맞는 운동 리스트를 가져오는 메서드
  List<String> _getExercisesForTargetArea(String targetArea) {
    if (targetArea.isEmpty) {
      return [];
    }
    return items
        .where((item) => item['category'] == targetArea)
        .map((item) => item['title']!)
        .toList();
  }

  // OpenAI API 호출 메서드
  Future<void> _sendDataToGPTAPI() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      print('API 키가 없습니다.');
      return;
    }

    if (height == null || weight == null || age == null || targetArea == null || goal == null) {
      print('모든 필드를 입력해주세요.');
      return;
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    List<String> exercisesForTargetArea = _getExercisesForTargetArea(targetArea ?? '');
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
            'content': 'You are a fitness expert. Please create 3 workout routines in the following JSON format: [{"routine": 1, "exercises": [{"name": "exercise1", "sets": "3", "reps": "12"}, {"name": "exercise2", "sets": "4", "reps": "10"}]}, {...}, {...}]. Here is the list of exercises to include: $exerciseString.',
          },
          {
            'role': 'user',
            'content': '저는 $age살이고, 키는 $height cm이며, 몸무게는 $weight kg입니다. '
                '운동 부위는 $targetArea이며, 목표는 $goal입니다. 3개의 루틴을 JSON 형태로 추천해주세요.',
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null) {
        List<dynamic> routinesData = jsonDecode(data['choices'][0]['message']['content']);
        List<List<String>> workoutRoutines = routinesData.map((routine) {
          return (routine['exercises'] as List<dynamic>).map((exercise) {
            return '${exercise['name']}: ${exercise['sets']} sets of ${exercise['reps']} reps';
          }).toList();
        }).toList();

        setState(() {
          routines = workoutRoutines;
        });
        _saveRoutinesToPrefs(workoutRoutines);
      } else {
        print('응답 데이터가 비어 있습니다.');
      }
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
              onPressed: () async {
                Navigator.of(context).pop();
                await _sendDataToGPTAPI();
              },
              child: Text('추천 받기'),
            ),
          ],
        );
      },
    );
  }

  // 루틴의 상세 내용을 다이얼로그로 표시
  void _showWorkoutRoutineDetail(List<String> workoutRoutine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('루틴 상세 정보'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: workoutRoutine.map((exercise) => Text(exercise)).toList(),
          ),
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
      appBar: AppBar(
        title: Text('AI 운동 추천'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: routines.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('루틴 ${index + 1}'), // 제목만 표시
                  onTap: () => _showWorkoutRoutineDetail(routines[index]), // 제목 클릭 시 상세 정보를 다이얼로그로 표시
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _showUserInfoInputDialog,
          child: Text('사용자 정보 입력'),
        ),
      ),
    );
  }
}
