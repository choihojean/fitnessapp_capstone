import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'screen_routine_table.dart';
// import 'package:knufit/material3_theme.dart';

class ScreenRoutine extends StatefulWidget {
  final Map<String, dynamic> user;

  const ScreenRoutine({required this.user, Key? key}) : super(key: key);

  @override
  _ScreenRoutineState createState() => _ScreenRoutineState();
}

class _ScreenRoutineState extends State<ScreenRoutine> {
  List<String> tableNames = [];
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadTableNames(); // 초기화 시 루틴 테이블 이름 로드
  }

  // 데이터베이스에서 루틴 테이블 이름을 불러오는 함수
  Future<void> _loadTableNames() async {
    final names = await dbHelper.getCreatedRoutineTables(widget.user['id']);
    setState(() {
      tableNames = names; // 불러온 루틴 이름을 상태에 저장
    });
  }

  @override
  Widget build(BuildContext context) {   
    return Scaffold(
      // 본문 내용
      body: tableNames.isEmpty
          ? const Center(child: Text('루틴이 없습니다.')) // 루틴이 없을 경우 표시
          : ListView.builder(
              padding: const EdgeInsets.all(16), // ListView의 패딩 설정
              itemCount: tableNames.length, // 리스트 아이템 수 설정
              itemBuilder: (context, index) {
                return Card(
                  key: ValueKey(tableNames[index]), // 각 카드에 고유 키 부여
                  margin: const EdgeInsets.symmetric(vertical: 8), // 카드 간의 수직 간격 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // 카드의 모서리를 둥글게 설정
                  ),
                  elevation: 4, // 카드의 그림자 깊이 설정
                  child: ListTile(
                    title: Text(
                      tableNames[index], // 루틴 이름 표시
                      style: Theme.of(context).textTheme.bodyLarge, // 테마의 bodyLarge 텍스트 스타일 적용
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red), // 삭제 아이콘 설정 및 색상 지정
                      tooltip: '루틴 삭제', // 아이콘의 툴팁 설정
                      onPressed: () async {
                        // 삭제 아이콘 클릭 시 확인 다이얼로그 표시
                        bool? confirmed = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('루틴 삭제'), // 다이얼로그 제목
                              content: const Text('이 루틴을 정말 삭제하시겠습니까?'), // 다이얼로그 내용
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false), // '취소' 버튼 클릭 시 다이얼로그 닫기
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true), // '삭제' 버튼 클릭 시 다이얼로그 닫고 삭제 확인
                                  child: const Text('삭제'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          // 삭제가 확인되면 데이터베이스에서 루틴 삭제
                          await dbHelper.deleteRoutineTable(widget.user['id'], tableNames[index]);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${tableNames[index]}이(가) 삭제되었습니다.')), // 삭제 완료 메시지 표시
                          );
                          _loadTableNames(); // 루틴 목록 갱신
                        }
                      },
                    ),
                    onTap: () async {
                      // 루틴 아이템을 탭했을 때 ScreenRoutineTable로 이동
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScreenRoutineTable(
                            tableName: tableNames[index],
                            user: widget.user,
                          ),
                        ),
                      );

                      if (result == true) {
                        _loadTableNames(); // ScreenRoutineTable에서 변경 사항이 있을 경우 루틴 목록 갱신
                      }
                    },
                  ),
                );
              },
            ),
      // 플로팅 액션 버튼 설정
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showInputDialog(context); // 플로팅 버튼 클릭 시 입력 다이얼로그 표시
          _loadTableNames(); // 루틴 목록 갱신
        },
        child: const Icon(Icons.add), // 플로팅 버튼에 추가 아이콘 설정
        tooltip: '루틴 추가', // 플로팅 버튼의 툴팁 설정
      ),
    );
  }

  // 루틴 이름을 입력받는 다이얼로그를 표시하는 함수
  Future<void> _showInputDialog(BuildContext context) async {
    final TextEditingController _controller = TextEditingController(); // 텍스트 필드 컨트롤러 생성

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('루틴 이름 입력'), // 다이얼로그 제목
          content: TextField(
            controller: _controller, // 입력 필드에 컨트롤러 연결
            decoration: const InputDecoration(
              hintText: '루틴 이름', // 입력 필드의 힌트 텍스트 설정
              border: OutlineInputBorder(), // 입력 필드의 테두리 설정
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // '취소' 버튼 클릭 시 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () async {
                String input = _controller.text.trim(); // 입력된 텍스트 가져오기 및 공백 제거
                if (input.isNotEmpty) {
                  if (_isValidTableName(input)) {
                    // 루틴 이름이 유효한지 검사
                    bool exists = await dbHelper.routineTableExists(widget.user['id'], input);
                    if (exists) {
                      // 이미 존재하는 루틴 이름일 경우 스낵바로 알림
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이미 존재하는 루틴 이름입니다')),
                      );
                    } else {
                      // 유효하고 중복되지 않은 루틴 이름일 경우 데이터베이스에 추가
                      await dbHelper.createRoutineTable(widget.user['id'], input);
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$input이(가) 추가되었습니다!')), // 추가 완료 메시지 표시
                      );
                    }
                  } else {
                    // 루틴 이름이 유효하지 않을 경우 스낵바로 알림
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('루틴의 이름이 잘못 되었습니다')),
                    );
                  }
                }
              },
              child: const Text('저장'), // '저장' 버튼 텍스트 설정
            ),
          ],
        );
      },
    );
  }

  // 루틴 이름의 유효성을 검사하는 함수
  bool _isValidTableName(String tableName) {
    if (RegExp(r'^[0-9]').hasMatch(tableName)) {
      return false; // 루틴 이름이 숫자로 시작하면 유효하지 않음
    }
    if (!RegExp(r'^[a-zA-Z0-9_\uac00-\ud7a3]+$').hasMatch(tableName)) {
      return false; // 허용된 문자(a-z, A-Z, 0-9, _, 한글) 외의 문자가 포함되면 유효하지 않음
    }
    return true; // 유효한 루틴 이름
  }
}
