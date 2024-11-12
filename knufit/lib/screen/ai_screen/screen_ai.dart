import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../training_screen/training_detail.dart';
import '../../exercise_model.dart';
import '../../database/db_helper.dart';

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String? height, weight, age;
  List<String> targetAreas = []; //사용자가 선택한 운동 부위를 저장할 리스트
  String? goal;
  List<List<Map<String, String>>> routines = []; //AI가 추천한 운동 루틴 목록을 저장할 리스트
  bool _isLoading = false;

  final DBHelper _dbHelper = DBHelper();

  final List<String> _allTargetAreas = [
    '가슴',
    '어깨',
    '승모',
    '등',
    '복근',
    '이두',
    '삼두',
    '전완',
    '둔근',
    '대퇴사두',
    '햄스트링',
    '종아리'
  ];
  final List<String> _goals = ['근력 증가', '다이어트', '유연성 향상'];

  @override
  void initState() {
    super.initState();
    _loadSavedRoutines();
  }

  // 추천받은 루틴을 SharedPreferences에 저장하는 메서드
  Future<void> _saveRoutinesToPrefs(
      List<List<Map<String, String>>> routines) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> routinesAsJsonString =
        routines.map((routine) => jsonEncode(routine)).toList();
    await prefs.setStringList(
        'saved_routines', routinesAsJsonString.take(6).toList());
  }

  // SharedPreferences에서 저장된 루틴을 불러오는 메서드
  Future<void> _loadSavedRoutines() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedRoutines = prefs.getStringList('saved_routines');
    if (savedRoutines != null) {
      setState(() {
        routines = savedRoutines.map((routine) {
          List<dynamic> decodedRoutine = jsonDecode(routine);
          return decodedRoutine.map<Map<String, String>>((exercise) {
            return Map<String, String>.from(exercise as Map);
          }).toList();
        }).toList();
      });
    }
  }


  //DB에서 사용자가 선택한 운동 부위에 맞는 운동 리스트를 가져오는 메서드
  Future<List<Exercise>> _getExercisesForTargetAreas() async {
    List<Exercise> exercisesForTargetAreas = [];
    for (String area in targetAreas) {
      List<Map<String, dynamic>> exercisesFromDB =
          await _dbHelper.getTrainingByCategory(area);
      exercisesForTargetAreas.addAll(exercisesFromDB
          .map((exercise) => Exercise.fromJson(exercise))
          .toList());
    }
    return exercisesForTargetAreas;
  }

  //OpenAI API를 호출하여 운동 루틴을 추천받는 메서드
  Future<void> _sendDataToGPTAPI() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      print('API 키가 없습니다.');
      return;
    }

    if (height == null ||
        weight == null ||
        age == null ||
        targetAreas.isEmpty ||
        goal == null) {
      print('모든 필드를 입력해주세요.');
      return;
    }

    //DB에서 운동 데이터를 가져와 문자열로 변환
    List<Exercise> exercisesForTargetAreas =
        await _getExercisesForTargetAreas();
    String exerciseString =
        exercisesForTargetAreas.map((exercise) => exercise.name).join(", ");

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'n': 2, // n파라미터 추가
        'messages': [
          {
            'role': 'system',
            'content': '''You are a fitness expert. Create 3 workout routines using only the exercises listed in $exerciseString.
            Each routine should have a unique title in Korean and include reasons for the recommendations, targeting a specific muscle group or workout area.
            Avoid simple titles like '근력 강화 루틴1, 근육 강화 루틴2'
            Each routine should contain 6-8 exercises in the following JSON format:
            [
              {"routine": {"title": "Title with specific exercise objectives", "reason": "Explanation for recommending this routine, including target area or workout benefits"}, 
                "exercises": [
                  {"name": "exercise1", "sets": "3", "reps": "12"},
                  {"name": "exercise2", "sets": "4", "reps": "10"}
                ]
              }, {...}, {...}
            ]''',
          },
          {
            'role': 'user',
            'content':
                '''I am $age years old, I am $height cm tall, and i weigh $weight kg.
                The exercise areas are the ${targetAreas.join(", ")}, and the goal is $goal.
                Please recommend 3 workout routines in JSON format, each containing Korean titles and reasons, with exercises included from $exerciseString.
                ''',
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
        List<List<Map<String, String>>> workoutRoutines = [];//추천 운동 루틴을 저장할 리스트
        
        for (var choice in data['choices']) {
          List<dynamic> routinesData = jsonDecode(choice['message']['content']);

          for (var routine in routinesData) {
            String routineTitle = routine['routine']['title'] ?? '$targetAreas 루틴';
            String routineReason = routine['routine']['reason'] ?? '루틴 추천 이유';

            List<Map<String, String>> exerciseList = (routine['exercises'] as List<dynamic>).map((exercise) {
              final matchedExercise = exercisesForTargetAreas.firstWhere(
                (item) => item.name == exercise['name'],
                orElse: () => Exercise(
                  name: '', // 이름을 빈 문자열로 설정하여 필터링에 사용
                  tip: '',
                  category: '',
                  movement: '',
                  precautions: '',
                  gif: '',
                  id: 0,
                  target: '',
                  preparation: '',
                  breathing: '',
                  img: '',
                ),
              );

              // 유효한 이름이 있는 운동만 추가
              if (matchedExercise.name.isNotEmpty) {
                return {
                  'name': matchedExercise.name,
                  'sets': exercise['sets'].toString(),
                  'reps': exercise['reps'].toString(),
                  'routinetitle': routineTitle,
                  'routinereason': routineReason,
                  'tip': matchedExercise.tip,
                  'category': matchedExercise.category,
                  'movement': matchedExercise.movement,
                  'precautions': matchedExercise.precautions,
                  'gif': matchedExercise.gif,
                  'target': matchedExercise.target,
                  'preparation': matchedExercise.preparation,
                  'breathing': matchedExercise.breathing,
                  'img': matchedExercise.img,
                };
              } else {
                return null; // 일치하지 않는 운동은 null을 반환하여 제외
              }
            })
            .where((exercise) => exercise != null) // null 값을 필터링하여 제외
            .cast<Map<String, String>>()
            .toList();
            workoutRoutines.add(exerciseList.take(8).toList()); //각 루틴에 최대 8개의 운동만 추가
          }
        }

        setState(() {
          routines = workoutRoutines;
        });
      _saveRoutinesToPrefs(workoutRoutines); //추천된 운동 루틴을 SharedPreferences에 저장
      } else {
        print('응답 데이터가 비어 있습니다.');
      }
    } else {
      print('추천 실패: ${response.body}');
    }
  }

  //사용자 정보 입력 다이얼로그
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
                      _showUserInfoInputDialog(); // 변경된 내용으로 다이얼로그 다시 열기
                    },
                    child: Text(targetAreas.isEmpty
                        ? '운동 부위 선택'
                        : '선택된 부위: ${targetAreas.join(", ")}'),
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

  //사용자가 여러 운동 부위를 선택할 수 있는 다이얼로그 표시 메서드
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
                    Navigator.of(context).pop(selectedAreas); //선택 항목 반환
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
          targetAreas = updatedAreas; //선택 항목 반영
        });
      }
    });
  }

  //루틴의 상세 내용을 다이얼로그로 표시
  void _showWorkoutRoutineDetail(List<Map<String, String>> workoutRoutine) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: workoutRoutine.map((exerciseData) {
                  // `Exercise` 객체로 변환
                  final exercise = Exercise(
                    name: exerciseData['name'] ?? '운동 이름 없음',
                    tip: exerciseData['tip'] ?? '',
                    category: exerciseData['category'] ?? '',
                    movement: exerciseData['movement'] ?? '',
                    precautions: exerciseData['precautions'] ?? '',
                    gif: exerciseData['gif'] ?? '',
                    id: int.tryParse(exerciseData['id'] ?? '0') ?? 0,
                    target: exerciseData['target'] ?? '',
                    preparation: exerciseData['preparation'] ?? '',
                    breathing: exerciseData['breathing'] ?? '',
                    img: exerciseData['img'] ?? '',
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
                              ? Image.network(
                                  exercise.img,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                )
                              : Icon(Icons.fitness_center),
                          title: Text(
                            exercise.name,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.target,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
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
                    // 루틴 제목 및 추천 이유 표시 부분 수정
                    itemBuilder: (context, index) {
                      String routineTitle = routines[index][0]
                              ['routinetitle'] ??
                          '루틴 ${index + 1}';
                      String routineReason =
                          routines[index][0]['routinereason'] ?? '추천 이유 없음';

                      return Card(
                        key: ValueKey('루틴 ${index + 1}'),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            routineTitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: Text(routineReason),
                          onTap: () =>
                              _showWorkoutRoutineDetail(routines[index]),
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




  

  