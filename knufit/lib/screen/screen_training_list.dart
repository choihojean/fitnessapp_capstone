import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수 로드
import 'package:http/http.dart' as http;
import '../exercise_model.dart';
import 'training_screen/training_detail.dart'; // 필요에 따라 경로 조정
import '../../training_list_model.dart'; // TrainingListItem 모델 임포트
import '../database/db_helper.dart';

class ScreenTrainingList extends StatefulWidget {
  final Map<String, dynamic> user; // 사용자 정보를 받을 변수

  ScreenTrainingList({required this.user, Key? key}) : super(key: key);

  @override
  _ScreenTrainingListState createState() => _ScreenTrainingListState();
}

class _ScreenTrainingListState extends State<ScreenTrainingList> {
  String searchQuery = ''; // 검색어를 저장할 변수
  TextEditingController searchController = TextEditingController();
  int selectedTabIndex = 0; // 선택된 탭의 인덱스를 저장
  final String? serverIp = dotenv.env['SERVER_IP'];

  final List<String> categories = [
    '전체',
    '가슴',
    '등',
    '어깨',
    '이두',
    '삼두',
    '전완',
    '복근',
    '둔근',
    '대퇴사두',
    '햄스트링',
    '승모',
    '종아리'
  ]; // 탭에 표시할 카테고리 목록

  // 상태 변수 추가
  final DBHelper _dbTraining = DBHelper(); // DBTraining 인스턴스 생성
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  String _error = '';

  // 루틴 관련 상태 변수
  List<TrainingListItem> _routines = [];
  bool _isLoadingRoutines = false;
  String _routinesError = '';

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  // 내부DB에서 운동 개수 비교 (같으면 true // 다르면 false)
  Future<bool> loadTrainingCount(int count) async {
    final uri = Uri.parse('http://$serverIp/training/count');
    var result = false;
    try {
      final response = await http.get(uri);
      if(response.statusCode == 200) {
        var temp = int.parse(response.body);
        result = count == temp ? true : false;
      }
    } catch(e) {
      print({"error": e});
    }
    return result;
  }

  // 서버에서 운동 로드
  Future<bool> loadTrainingToServer() async {
    final uri = Uri.parse('http://$serverIp/training');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _exercises = jsonData.map((json) => Exercise.fromJson(json)).toList();
        });
        return true;
      } else {
        setState(() {
          _error = '운동 데이터를 불러오지 못했습니다: ${response.statusCode}';
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _error = '에러 발생: $e';
      });
      return false;
    }
  }

  // 운동 데이터 로드 메서드
  Future<void> loadExercises() async {
    if (serverIp == null) {
      setState(() {
        _error = 'SERVER_IP가 .env 파일에 정의되어 있지 않습니다.';
        _isLoading = false;
      });
      return;
    }

    final exerciseCount = await _dbTraining.readTrainingAllCount();
    print('운동 개수 ======== $exerciseCount');
    if(exerciseCount != 0) {
      if(await loadTrainingCount(exerciseCount)) { // 내부db O, 크기 같음
        List<Map<String, dynamic>> tempExercises1 = await _dbTraining.readTrainingAll();
        _exercises = tempExercises1.map((exercise) => Exercise.fromJson(exercise)).toList();
        _isLoading = false;
        return;
      }
      else { // 내부db O, 크기 다름
        await _dbTraining.deleteTraining();
      }
    }
    if(await loadTrainingToServer()) { // 서버에서 데이터 로드 성공
      List<Map<String, dynamic>> tempExercises2 = _exercises.map((exercise) => exercise.toJson()).toList();
      await _dbTraining.createTraining(tempExercises2);
      _isLoading = false;
      return;
    }
    _isLoading = false;
  }

  // 루틴에 운동 추가 메서드 완성
  Future<void> _addTraining(int userId, int listId, int trainingId) async {
    print("운동 추가: $userId // $listId // $trainingId");

    if (serverIp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SERVER_IP가 .env 파일에 정의되어 있지 않습니다.')),
      );
      return;
    }

    setState(() {
      _isLoadingRoutines = true;
      _routinesError = '';
    });

    final Uri uri = Uri.parse('http://$serverIp/traininglistdetail');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'training_list_id': listId,
          'training_id': trainingId,
          'content': "운동 메모" // 필요 시 사용자 입력으로 대체 가능
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('루틴에 운동이 추가되었습니다.')),
        );
        setState(() {
          _isLoadingRoutines = false;
        });
        // 필요 시 루틴 목록을 다시 로드하거나 UI를 갱신
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운동 추가에 실패했습니다.')),
        );
        print('요청 실패: ${response.statusCode}');
        print('응답 내용: ${response.body}');
        setState(() {
          _isLoadingRoutines = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('운동 추가 중 오류가 발생했습니다.')),
      );
      print('에러 발생: $e');
      setState(() {
        _routinesError = '에러 발생: $e';
        _isLoadingRoutines = false;
      });
    }
  }

  // 루틴 목록 로드 메서드
  Future<void> _loadRoutines() async {
    if (serverIp == null) {
      setState(() {
        _routinesError = 'SERVER_IP가 .env 파일에 정의되어 있지 않습니다.';
      });
      return;
    }

    setState(() {
      _isLoadingRoutines = true;
      _routinesError = '';
    });

    final Uri uri = Uri.parse('http://$serverIp/traininglist').replace(queryParameters: {
      'userid': '${widget.user['id']}',
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _routines = data.map((item) => TrainingListItem.fromJson(item)).toList();
          _isLoadingRoutines = false;
        });
      } else {
        setState(() {
          _routinesError = '루틴을 불러오지 못했습니다: ${response.statusCode}';
          _isLoadingRoutines = false;
        });
      }
    } catch (e) {
      setState(() {
        _routinesError = '에러 발생: $e';
        _isLoadingRoutines = false;
      });
    }
  }

  // 바텀 시트 열기 메서드 수정
  void _showRoutinesBottomSheet(int trainingId) async {
    await _loadRoutines();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        if (_isLoadingRoutines) {
          return Container(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (_routinesError.isNotEmpty) {
          return Container(
            height: 200,
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text(_routinesError)),
          );
        } else if (_routines.isEmpty) {
          return Container(
            height: 200,
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('생성된 루틴이 없습니다.')),
          );
        } else {
          return Container(
            height: 300,
            child: ListView.builder(
              itemCount: _routines.length,
              itemBuilder: (context, index) {
                final routine = _routines[index];
                return ListTile(
                  title: Text(routine.name),
                  onTap: () {
                    Navigator.pop(context);
                    _addTraining(widget.user['id'], routine.id, trainingId);
                  },
                );
              },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('운동 목록'),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 삭제
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              width: 200,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '운동 검색',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.orange), // 테두리 색상 설정
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.orange), // 포커스 시 테두리 색상 설정
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.orange), // 활성화된 상태의 테두리 색상 설정
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0), // 텍스트 위치 조정
                  hintStyle: TextStyle(
                    color: Colors.grey, // 힌트 텍스트 색상 설정
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // 검색어를 저장
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 탭을 보여줄 부분
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTabIndex = index;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: selectedTabIndex == index
                          ? Colors.orange
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: selectedTabIndex == index
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 선택된 탭에 따른 콘텐츠를 보여줄 부분
          Expanded(
            child: buildListView(categories[selectedTabIndex]),
          ),
        ],
      ),
      // FloatingActionButton 제거
    );
  }

  Widget buildListView(String category) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    } else {
      List<Exercise> filteredExercises = _exercises;

      // 카테고리 필터 적용
      if (category != '전체') {
        filteredExercises = filteredExercises.where((exercise) => exercise.category == category).toList();
      }

      // 검색어 필터 적용
      if (searchQuery.isNotEmpty) {
        filteredExercises = filteredExercises.where((exercise) => exercise.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }

      if (filteredExercises.isEmpty) {
        return Center(child: Text('검색 결과가 없습니다.'));
      }

      return ListView.builder(
        itemCount: filteredExercises.length,
        itemBuilder: (context, index) {
          final exercise = filteredExercises[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: Image.network(
                exercise.img,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 50);
                },
              ),
              title: Text(exercise.name),
              subtitle: Text(exercise.target),
              trailing: IconButton(
                icon: Icon(Icons.add, color: Colors.orange),
                onPressed: () {
                  _showRoutinesBottomSheet(exercise.id);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrainingDetail(exercise: exercise.toJson()),
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }
}




// import 'package:flutter/material.dart';
// import 'package:knufit/screen/training_screen/training_detail.dart';
// import '../../database/db_helper.dart'; // DBHelper 클래스를 import
// //import 'training_screen/training_list.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수 로드
// import 'package:http/http.dart' as http;

// class ScreenTrainingList extends StatefulWidget {
//   final Map<String, dynamic> user; // 사용자 정보를 받을 변수

//   ScreenTrainingList({required this.user, Key? key}) : super(key: key);

//   @override
//   _ScreenTrainingListState createState() => _ScreenTrainingListState();
// }

// class _ScreenTrainingListState extends State<ScreenTrainingList> {
//   String searchQuery = ''; // 검색어를 저장할 변수
//   TextEditingController searchController = TextEditingController();
//   int selectedTabIndex = 0; // 선택된 탭의 인덱스를 저장

//   final List<String> categories = [
//     '전체',
//     '가슴',
//     '등',
//     '어깨',
//     '이두',
//     '삼두',
//     '전완',
//     '복근',
//     '둔근',
//     '대퇴사두',
//     '햄스트링',
//     '승모',
//     '종아리'
//   ]; // 탭에 표시할 카테고리 목록

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('운동 목록'),
//         automaticallyImplyLeading: false, // 뒤로 가기 버튼 삭제
//         actions: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//             child: Container(
//               width: 200,
//               child: TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: '운동 검색',
//                   prefixIcon: Icon(Icons.search),
//                   suffixIcon: searchController.text.isNotEmpty
//                       ? IconButton(
//                           icon: Icon(Icons.cancel, color: Colors.grey),
//                           onPressed: () {
//                             setState(() {
//                               searchController.clear();
//                               searchQuery = '';
//                             });
//                           },
//                         )
//                       : null,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide(color: Colors.orange), // 테두리 색상 설정
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide(color: Colors.orange), // 포커스 시 테두리 색상 설정
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide(color: Colors.orange), // 활성화된 상태의 테두리 색상 설정
//                   ),
//                   contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0), // 텍스트 위치 조정
//                   hintStyle: TextStyle(
//                     color: Colors.grey, // 힌트 텍스트 색상 설정
//                   ),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     searchQuery = value; // 검색어를 저장
//                   });
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // 탭을 보여줄 부분
//           SizedBox(
//             height: 50,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedTabIndex = index;
//                     });
//                   },
//                   child: Container(
//                     alignment: Alignment.center,
//                     padding: EdgeInsets.symmetric(horizontal: 16.0),
//                     margin: EdgeInsets.symmetric(horizontal: 4.0),
//                     decoration: BoxDecoration(
//                       color: selectedTabIndex == index
//                           ? Colors.orange
//                           : Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       categories[index],
//                       style: TextStyle(
//                         color: selectedTabIndex == index
//                             ? Colors.white
//                             : Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           // 선택된 탭에 따른 콘텐츠를 보여줄 부분
//           Expanded(
//             child: buildListView(categories[selectedTabIndex]),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         heroTag: 'trainingList',
//         onPressed: () {
//           _showInputDialog(context);
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   Widget buildListView(String category) {
//     List<Map<String, String>> filteredItems;
//     if (category == '전체') {
//       filteredItems = items;
//     } else {
//       filteredItems = items.where((item) => item['category'] == category).toList();
//     }

//     // 검색어가 있을 경우 필터링
//     if (searchQuery.isNotEmpty) {
//       filteredItems = filteredItems
//           .where((item) => item['title']!.toLowerCase().contains(searchQuery))
//           .toList();
//     }

//     return ListView.builder(
//       itemCount: filteredItems.length,
//       itemBuilder: (context, index) {
//         final item = filteredItems[index];
//         return ListTile(
//           leading: Image.asset(
//             item['image']!,
//             width: 50,
//             height: 50,
//             fit: BoxFit.contain,
//           ),
//           title: Text(item['title']!),
//           subtitle: Text(
//             item['subtitle']!,
//             style: TextStyle(
//               color: Colors.grey.withOpacity(0.9), // subtitle의 투명도 설정
//             ),
//           ),
//           trailing: IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               _showBottomSheet(context, item); // 선택된 운동 데이터를 함께 전달
//             },
//           ),
//           onTap: () {
//           // 운동 항목 클릭 시 상세 페이지로 이동
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => TrainingDetail(exercise: item),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   void _showBottomSheet(BuildContext context, Map<String, String> selectedExercise) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return FutureBuilder<List<String>>(
//           future: _loadRoutineTables(), // 데이터베이스에서 루틴 테이블을 불러옴
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error: ${snapshot.error}'));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(child: Text('저장된 루틴 테이블이 없습니다.'));
//             } else {
//               List<String> tableNames = snapshot.data!;
//               return Container(
//                 height: MediaQuery.of(context).size.height * 0.5, // 바텀 시트 높이 설정
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Text(
//                         '루틴에 운동 추가 하기', // 바텀 시트 상단에 추가할 텍스트
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: tableNames.length,
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             title: Text(tableNames[index]),
//                             onTap: () async {
//                               // 선택된 루틴 테이블에 운동 데이터를 저장
//                               await _saveExerciseToRoutine(tableNames[index], selectedExercise);
//                               Navigator.pop(context); // 바텀 시트를 닫기
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           },
//         );
//       },
//     );
//   }

//   Future<void> _saveExerciseToRoutine(String tableName, Map<String, String> exerciseData) async {
//     final dbHelper = DBHelper();
//     await dbHelper.insertRoutineData(tableName, {
//       'title': exerciseData['title'],
//       'content': exerciseData['subtitle'],
//       'image': exerciseData['image'],
//       'category': exerciseData['category'],
//       'memo': exerciseData['title'],
//     });
//   }

//   Future<List<String>> _loadRoutineTables() async {
//     final dbHelper = DBHelper();
//     return await dbHelper.getCreatedRoutineTables(widget.user['id']);
//   }

//   void _showInputDialog(BuildContext context) {
//     final TextEditingController _controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('루틴 이름 입력'),
//           content: TextField(
//             controller: _controller,
//             decoration: InputDecoration(hintText: '루틴 이름'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('취소'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String input = _controller.text;
//                 if (input.isNotEmpty) {
//                   // 입력된 이름의 유효성을 검사
//                   if (_isValidTableName(input)) {
//                     final dbHelper = DBHelper();

//                     // 이미 존재하는 테이블 이름인지 확인
//                     bool exists = await dbHelper.routineTableExists(widget.user['id'], input);
//                     if (exists) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('이미 존재하는 루틴 이름입니다')),
//                       );
//                     } else {
//                       await dbHelper.createRoutineTable(widget.user['id'], input);
//                       Navigator.of(context).pop();
//                       // 필요한 경우, 새로 추가된 루틴을 화면에 반영하는 로직 추가 가능
//                     }
//                   } else {
//                     // 유효하지 않은 이름인 경우 스낵바 표시
//                     Navigator.of(context).pop();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('루틴의 이름이 잘못 되었습니다')),
//                     );
//                   }
//                 }
//               },
//               child: Text('저장'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // 테이블 이름 유효성 검사 함수
//   bool _isValidTableName(String tableName) {
//     // 테이블 이름이 숫자로 시작하면 안 됨
//     if (RegExp(r'^[0-9]').hasMatch(tableName)) {
//       return false;
//     }
//     // 유효한 문자만 포함해야 함 (문자, 숫자, 밑줄, 한글 등)
//     if (!RegExp(r'^[a-zA-Z0-9_\uac00-\ud7a3]+$').hasMatch(tableName)) {
//       return false;
//     }
//     return true;
//   }
// }
