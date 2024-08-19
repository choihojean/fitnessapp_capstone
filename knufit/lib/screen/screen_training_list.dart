import 'package:flutter/material.dart';
import 'package:knufit/screen/training_screen/training_detail.dart';
import '../../database/db_helper.dart'; // DBHelper 클래스를 import
import 'training_screen/training_list.dart';

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
      floatingActionButton: FloatingActionButton(
        heroTag: 'trainingList',
        onPressed: () {
          _showInputDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildListView(String category) {
    List<Map<String, String>> filteredItems;
    if (category == '전체') {
      filteredItems = items;
    } else {
      filteredItems = items.where((item) => item['category'] == category).toList();
    }

    // 검색어가 있을 경우 필터링
    if (searchQuery.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) => item['title']!.toLowerCase().contains(searchQuery))
          .toList();
    }

    return ListView.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return ListTile(
          leading: Image.asset(
            item['image']!,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          title: Text(item['title']!),
          subtitle: Text(
            item['subtitle']!,
            style: TextStyle(
              color: Colors.grey.withOpacity(0.9), // subtitle의 투명도 설정
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showBottomSheet(context, item); // 선택된 운동 데이터를 함께 전달
            },
          ),
          onTap: () {
          // 운동 항목 클릭 시 상세 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainingDetail(exercise: item),
              ),
            );
          },
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, Map<String, String> selectedExercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FutureBuilder<List<String>>(
          future: _loadRoutineTables(), // 데이터베이스에서 루틴 테이블을 불러옴
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('저장된 루틴 테이블이 없습니다.'));
            } else {
              List<String> tableNames = snapshot.data!;
              return Container(
                height: MediaQuery.of(context).size.height * 0.5, // 바텀 시트 높이 설정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '루틴에 운동 추가 하기', // 바텀 시트 상단에 추가할 텍스트
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: tableNames.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(tableNames[index]),
                            onTap: () async {
                              // 선택된 루틴 테이블에 운동 데이터를 저장
                              await _saveExerciseToRoutine(tableNames[index], selectedExercise);
                              Navigator.pop(context); // 바텀 시트를 닫기
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _saveExerciseToRoutine(String tableName, Map<String, String> exerciseData) async {
    final dbHelper = DBHelper();
    await dbHelper.insertRoutineData(tableName, {
      'title': exerciseData['title'],
      'content': exerciseData['subtitle'],
      'image': exerciseData['image'],
      'category': exerciseData['category'],
    });
  }

  Future<List<String>> _loadRoutineTables() async {
    final dbHelper = DBHelper();
    return await dbHelper.getCreatedRoutineTables(widget.user['id']);
  }

  void _showInputDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('루틴 이름 입력'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: '루틴 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                String input = _controller.text;
                if (input.isNotEmpty) {
                  // 입력된 이름의 유효성을 검사
                  if (_isValidTableName(input)) {
                    // DBHelper 인스턴스를 생성하여 새로운 테이블을 생성하는 메소드 호출
                    final dbHelper = DBHelper();
                    await dbHelper.createRoutineTable(widget.user['id'], input); // 사용자 ID 포함
                    Navigator.of(context).pop();
                  } else {
                    // 유효하지 않은 이름인 경우 스낵바 표시
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('루틴의 이름이 잘못 되었습니다')),
                    );
                  }
                }
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // 테이블 이름 유효성 검사 함수
  bool _isValidTableName(String tableName) {
    // 테이블 이름이 숫자로 시작하면 안 됨
    if (RegExp(r'^[0-9]').hasMatch(tableName)) {
      return false;
    }
    // 유효한 문자만 포함해야 함 (문자, 숫자, 밑줄, 한글 등)
    if (!RegExp(r'^[a-zA-Z0-9_\uac00-\ud7a3]+$').hasMatch(tableName)) {
      return false;
    }
    return true;
  }
}