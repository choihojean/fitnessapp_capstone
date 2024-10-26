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
  String? height, weight, age;
  String? targetArea;
  String? goal;
  List<List<Map<String, String>>> routines = [];
  bool _isLoading = false;

  final List<String> _targetAreas = ['가슴', '어깨', '승모', '등', '복근', '이두', '삼두', '전완', '둔근', '대퇴사두', '햄스트링', '종아리'];
  final List<String> _goals = ['근력 증가', '다이어트', '유연성 향상'];

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
        routines = savedRoutines.map((routine) => routine.split(', ').map((e) => {'title': e}).toList()).toList();
      });
    }
  }

  // 추천받은 루틴을 SharedPreferences에 저장하는 메서드
  Future<void> _saveRoutinesToPrefs(List<List<Map<String, String>>> routines) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> routinesAsString = routines.map((routine) => routine.map((e) => e['title']!).join(', ')).toList();
    await prefs.setStringList('saved_routines', routinesAsString);
  }

  // 타겟 부위에 맞는 최소 3개의 운동 리스트를 가져오는 메서드
  List<Map<String, String>> _getExercisesForTargetArea(String targetArea) {
    if (targetArea.isEmpty) {
      return [];
    }
    List<Map<String, String>> filteredItems = items
        .where((item) => item['category'] == targetArea)
        .toList();

    return filteredItems;
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
    List<Map<String, String>> exercisesForTargetArea = _getExercisesForTargetArea(targetArea ?? '');
    String exerciseString = exercisesForTargetArea.map((exercise) => exercise['title']!).join(", ");

    setState(() {
      _isLoading = true;
    });

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
            'content': 'You are a fitness expert. Please create 3 workout routines. Each routine should have at least 3 exercises in the following JSON format: [{"routine": 1, "exercises": [{"name": "exercise1", "sets": "3", "reps": "12"}, {"name": "exercise2", "sets": "4", "reps": "10"}]}, {...}, {...}]. Here is the list of exercises to include: $exerciseString.',
          },
          {
            'role': 'user',
            'content': '저는 $age살이고, 키는 $height cm이며, 몸무게는 $weight kg입니다. '
                '운동 부위는 $targetArea이며, 목표는 $goal입니다. 신체 정보와 운동 부위, 목표를 고려하여 3개의 루틴을 JSON 형태로 추천해주세요.',
          },
        ],
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data != null) {
        List<dynamic> routinesData = jsonDecode(data['choices'][0]['message']['content']);
        List<List<Map<String, String>>> workoutRoutines = routinesData.map((routine) {
          List<Map<String, String>> exerciseList = (routine['exercises'] as List<dynamic>).map((exercise) {
            // 운동명에 따라 items에서 해당 운동의 세부 정보를 찾습니다.
            Map<String, String> matchedExercise = exercisesForTargetArea.firstWhere(
              (item) => item['title'] == exercise['name'], 
              orElse: () => {'title': '운동 정보를 찾을 수 없습니다'}
            );
            matchedExercise['sets'] = exercise['sets'];
            matchedExercise['reps'] = exercise['reps'];
            return matchedExercise;
          }).toList();

          // 만약 운동이 3개 미만일 경우 추가 운동을 포함시킴
          if (exerciseList.length < 3) {
            List<Map<String, String>> additionalExercises = exercisesForTargetArea
                .where((exercise) => !exerciseList.contains(exercise))
                .take(3 - exerciseList.length)
                .toList();
            exerciseList.addAll(additionalExercises);
          }

          return exerciseList;
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

  // 폼을 통해 사용자가 입력한 정보를 받는 메서드 (Dropdown 추가)
  void _showUserInfoInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('사용자 정보 입력'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: '키 (cm)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '키를 입력해주세요';
                      }
                      return null;
                    },
                    onChanged: (value) => height = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '몸무게 (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '몸무게를 입력해주세요';
                      }
                      return null;
                    },
                    onChanged: (value) => weight = value,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: '나이'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '나이를 입력해주세요';
                      }
                      return null;
                    },
                    onChanged: (value) => age = value,
                  ),
                  DropdownButtonFormField<String>(
                    value: targetArea,
                    items: _targetAreas.map((area) {
                      return DropdownMenuItem(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: '운동 부위'),
                    onChanged: (value) {
                      targetArea = value;
                    },
                    validator: (value) => value == null ? '운동 부위를 선택해주세요' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: goal,
                    items: _goals.map((goalItem) {
                      return DropdownMenuItem(
                        value: goalItem,
                        child: Text(goalItem),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: '목표'),
                    onChanged: (value) {
                      goal = value;
                    },
                    validator: (value) => value == null ? '목표를 선택해주세요' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  setState(() {}); // UI 갱신
                  await _sendDataToGPTAPI();
                }
              },
              child: Text('추천 받기'),
            ),
          ],
        );
      },
    );
  }

  // 루틴의 상세 내용을 다이얼로그로 표시 (여러 운동 포함)
  void _showWorkoutRoutineDetail(List<Map<String, String>> workoutRoutine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: workoutRoutine.map((exercise) {
                  // 각 운동의 세부 정보를 가져와 TrainingDetail의 UI 스타일로 구성
                  List<String> preparationSteps = exercise['preparation']?.split("\n") ?? [];
                  List<String> movementSteps = exercise['movement']?.split("\n") ?? [];
                  List<String> precautions = exercise['precautions']?.split("\n") ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 운동 이미지
                      if (exercise['image'] != null)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              exercise['image']!,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      SizedBox(height: 16),

                      // 운동 제목 및 부제목
                      Text(
                        exercise['title'] ?? '',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        exercise['subtitle'] ?? '',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 16),

                      // 세트/반복 횟수 표시
                      Text(
                        '세트: ${exercise['sets']} 세트, 반복: ${exercise['reps']} 회',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),

                      // 팁 섹션
                      _buildCardSection(
                        title: "운동 팁",
                        content: exercise['tip'] ?? '',
                        icon: Icons.lightbulb,
                      ),
                      SizedBox(height: 16),

                      // 운동 설명 섹션 (준비, 움직임, 호흡법)
                      _buildExerciseDetailsSection(
                        preparation: preparationSteps,
                        movement: movementSteps,
                        breathing: exercise['breathing'] ?? '',
                      ),
                      SizedBox(height: 16),

                      // 주의사항 섹션
                      _buildOrderedListSection(
                        title: "주의사항",
                        items: precautions,
                        icon: Icons.warning,
                      ),
                      Divider(height: 32), // 각 운동 구분선
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

// TrainingDetail의 UI를 재사용하는 함수들
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI 운동 추천'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 표시할 인디케이터
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('루틴 ${index + 1}'),
                        onTap: () => _showWorkoutRoutineDetail(routines[index]), // 루틴에 여러 운동 표시
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
