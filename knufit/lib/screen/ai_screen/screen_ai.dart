import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../training_screen/training_list.dart';
import '../training_screen/training_detail.dart';
import '../../exercise_model.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String? height, weight, age;
  List<String> targetAreas = []; // 여러 운동 부위를 저장할 리스트
  String? goal;
  List<List<Map<String, String>>> routines = [];
  bool _isLoading = false;

  final List<String> _allTargetAreas = ['가슴', '어깨', '승모', '등', '복근', '이두', '삼두', '전완', '둔근', '대퇴사두', '햄스트링', '종아리'];
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

    if (height == null || weight == null || age == null || targetAreas.isEmpty || goal == null) {
      print('모든 필드를 입력해주세요.');
      return;
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    // 여러 선택된 운동 부위의 운동을 가져옴
    List<Map<String, String>> exercisesForTargetAreas = targetAreas
        .expand((area) => _getExercisesForTargetArea(area))
        .toList();

    String exerciseString = exercisesForTargetAreas.map((exercise) => exercise['title']!).join(", ");

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
        'n': 4,  // n파라미터 추가
        'messages': [
          {
            'role': 'system',
            'content': 'You are a fitness expert. Please create 1 workout routine. Each routine should have 4-5 exercises in the following JSON format: [{"routine": 1, "exercises": [{"name": "exercise1", "sets": "3", "reps": "12"}, {"name": "exercise2", "sets": "4", "reps": "10"}]}, {...}, {...}]. Here is the list of exercises to include: $exerciseString.',
          },
          {
            'role': 'user',
            'content': '저는 $age살이고, 키는 $height cm이며, 몸무게는 $weight kg입니다. '
              '운동 부위는 ${targetAreas.join(", ")}이며, 목표는 $goal입니다. 루틴을 JSON 형태로 추천해주세요.',
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
        List<List<Map<String, String>>> workoutRoutines = [];

        // 각 choice에서 루틴 정보를 파싱하여 workoutRoutines에 추가
        for (var choice in data['choices']) {
          List<dynamic> routinesData = jsonDecode(choice['message']['content']);
        
          for (var routine in routinesData) {
            List<Map<String, String>> exerciseList = (routine['exercises'] as List<dynamic>).map((exercise) {
              // 운동명에 따라 items에서 해당 운동의 세부 정보를 탐색
              Map<String, String> matchedExercise = exercisesForTargetAreas.firstWhere(
                (item) => item['title'] == exercise['name'], 
                orElse: () => {'title': '운동 정보를 찾을 수 없습니다'}
              );
              matchedExercise['sets'] = exercise['sets'];
              matchedExercise['reps'] = exercise['reps'];
              return matchedExercise;
            }).toList();

            // 최대 5개 운동
            workoutRoutines.add(exerciseList.take(5).toList());
          }
        }

        setState(() {
          routines = workoutRoutines; // 각 루틴을 리스트로 저장
        });
        _saveRoutinesToPrefs(workoutRoutines);
      } else {
        print('응답 데이터가 비어 있습니다.');
      }
    } else {
      print('추천 실패: ${response.body}');
    }
  }

  // 사용자 정보 입력 다이얼로그
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
                ElevatedButton(
                  onPressed: () async {
                    await _showTargetAreaSelectionDialog();
                    Navigator.of(context).pop(); // 기존 다이얼로그 닫기
                    _showUserInfoInputDialog();  // 변경된 내용으로 다이얼로그 다시 열기
                  },
                  child: Text(targetAreas.isEmpty ? '운동 부위 선택' : '선택된 부위: ${targetAreas.join(", ")}'),
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

// 운동 부위 선택을 위한 다중 선택 다이얼로그
Future<void> _showTargetAreaSelectionDialog() async {
  final List<String> selectedAreas = List.from(targetAreas); // 기존 선택 항목 복사
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("운동 부위 선택"),
            content: SingleChildScrollView(
              child: Column(
                children: _allTargetAreas.map((area) {
                  return CheckboxListTile(
                    title: Text(area),
                    value: selectedAreas.contains(area),
                    onChanged: (isChecked) {
                      setState(() {
                        if (isChecked ?? false) {
                          selectedAreas.add(area);
                        } else {
                          selectedAreas.remove(area);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedAreas); // 선택 항목 반환
                },
                child: Text("확인"),
              ),
            ],
          );
        },
      );
    },
  ).then((updatedAreas) {
    if (updatedAreas != null) {
      setState(() {
        targetAreas = updatedAreas; // 선택 항목 반영
      });
    }
  });
}

  // 루틴의 상세 내용을 다이얼로그로 표시
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
              children: workoutRoutine.map((exerciseData) {
                // `Exercise` 객체로 변환
                final exercise = Exercise(
                  name: exerciseData['title'] ?? '운동 이름 없음',
                  tip: exerciseData['tip'] ?? '',
                  category: exerciseData['category'] ?? '',
                  movement: exerciseData['movement'] ?? '',
                  precautions: exerciseData['precautions'] ?? '',
                  gif: exerciseData['gif'] ?? '',
                  id: int.tryParse(exerciseData['id'] ?? '0') ?? 0,
                  target: exerciseData['subtitle'] ?? '', //target으로 하면 안나옴.
                  preparation: exerciseData['preparation'] ?? '',
                  breathing: exerciseData['breathing'] ?? '',
                  img: exerciseData['image'] ?? '',
                );

                return GestureDetector(
                  onTap: () {
                    // `Exercise` 객체의 `toJson()`을 사용해 `TrainingDetail`로 전달
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TrainingDetail(
                          exercise: exercise.toJson(),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: exercise.img.isNotEmpty
                            ? Image.asset(
                                exercise.img,
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              )
                            : Icon(Icons.fitness_center),
                        title: Text(
                          exercise.name,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.target,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '세트: ${exerciseData['sets'] ?? 'N/A'} 세트, 반복: ${exerciseData['reps'] ?? 'N/A'} 회',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    },
  );
}

  // 재사용 가능한 UI 컴포넌트
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
            _buildSectionTitle("호흡법"),
            Text(breathing, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      '- $title',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

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
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      return Card(
                        key: ValueKey('루틴 ${index + 1}'),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            '루틴 ${index + 1}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          onTap: () => _showWorkoutRoutineDetail(routines[index]),
                        ),
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
