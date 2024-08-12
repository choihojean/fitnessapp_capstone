import 'package:flutter/material.dart';
import '../../database/db_helper.dart'; // DBHelper 클래스를 import

class ScreenTrainingList extends StatelessWidget {
  final Map<String, dynamic> user; // 사용자 정보를 받을 변수

  ScreenTrainingList({required this.user, Key? key}) : super(key: key);

  final List<Map<String, String>> items = [
    //등
    {
      'title': '랫 풀 다운',
      'subtitle': '등, 이두',
      'image': 'assets/back/lat-pulldown.png',
    },
    {
      'title': '원 암 랫 풀 다운',
      'subtitle': '등, 이두',
      'image': 'assets/back/one-arm-lat-pulldown.png',
    },
    {
      'title': '클로스 그립 랫 풀 다운',
      'subtitle': '등, 어깨',
      'image': 'assets/back/close-grip-lat-pulldown.png',
    },

    {
      'title': '케이블 스트레이트 암 풀 다운',
      'subtitle': '등, 어깨',
      'image': 'assets/back/cable-straight-arm-pulldown.png',
    },

    {
      'title': '풀 업',
      'subtitle': '등, 이두',
      'image': 'assets/back/pull-up.png',
    },
    {
      'title': '중량 풀업',
      'subtitle': '등, 이두',
      'image': 'assets/back/weighted-pull-up.png',
    },
    {
      'title': '어시스티드 머신 풀업',
      'subtitle': '등, 이두',
      'image': 'assets/back/assisted-pull-up.png',
    },
    {
      'title': '밴드 풀 업',
      'subtitle': '등, 이두',
      'image': 'assets/back/band-pull-up.png',
    },

    {
      'title': '친 업',
      'subtitle': '등, 전완',
      'image': 'assets/back/chin-up.png',
    },
    {
      'title': '중량 친 업',
      'subtitle': '등, 전완',
      'image': 'assets/back/weighted-chin-up.png',
    },
    {
      'title': '밴드 친 업',
      'subtitle': '등, 전완',
      'image': 'assets/back/band-chin-up.png',
    },

    {
      'title': '케이블 시티드 로우',
      'subtitle': '등, 이두',
      'image': 'assets/back/cable-seated-row.png',
    },
    {
      'title': '바벨 로우(벤트 오버 바벨 로우)',
      'subtitle': '등, 이두',
      'image': 'assets/back/barbell-row.png',
    },
    {
      'title': '펜들레이 로우',
      'subtitle': '등',
      'image': 'assets/back/pendlay-row.png',
    },
    {
      'title': '티 바 로우',
      'subtitle': '등, 이두',
      'image': 'assets/back/t-bar-row.png',
    },
    {
      'title': '인버티드 로우',
      'subtitle': '등, 이두',
      'image': 'assets/back/inverted-row.png',
    },

    {
      'title': '덤벨 로우(벤트 오버 덤벨 로우)',
      'subtitle': '등, 이두',
      'image': 'assets/back/dumbbell-row.png',
    },
    {
      'title': '원 암 덤벨 로우',
      'subtitle': '등, 이두',
      'image': 'assets/back/one-arm-dumbbell-row.png',
    },
    {
      'title': '덤벨 리어 델트 로우',
      'subtitle': '등, 어깨',
      'image': 'assets/back/dumbbell-rear-delt-row.png',
    },

    {
      'title': '백 익스텐션',
      'subtitle': '등, 둔근',
      'image': 'assets/back/back-extension.png',
    },

    //가슴
    {
      'title': '바벨 벤치 프레스',
      'subtitle': '가슴, 삼두',
      'image': 'assets/chest/barbell-bench-press.png',
    },
    {
      'title': '바벨 인클라인 벤치 프레스',
      'subtitle': '가슴, 삼두',
      'image': 'assets/chest/barbell-incline-bench-press.png',
    },
    {
      'title': '바벨 디클라인 벤치 프레스',
      'subtitle': '가슴, 삼두',
      'image': 'assets/chest/barbell-decline-bench-press.png',
    },

    {
      'title': '덤벨 벤치 프레스',
      'subtitle': '가슴, 삼두',
      'image': 'assets/chest/dumbbell-bench-press.png',
    },
    {
      'title': '덤벨 인클라인 벤치 프레스',
      'subtitle': '가슴, 삼두',
      'image': 'assets/chest/dumbbell-incline-bench-press.png',
    },

    {
      'title': '머신 체스트 프레스',
      'subtitle': '가슴, 어깨',
      'image': 'assets/chest/machine-chest-press.png',
    },
    {
      'title': '랜드마인 체스트 프레스',
      'subtitle': '가슴, 어깨',
      'image': 'assets/chest/landmine-chest-press.png',
    },
    {
      'title': '덤벨 헥스 프레스',
      'subtitle': '가슴, 어깨',
      'image': 'assets/chest/dumbbell-hex-press.png',
    },
    {
      'title': '스벤드 프레스',
      'subtitle': '가슴, 삼두',
      'image': 'assets/chest/svend-press.png',
    },

    {
      'title': '케이블 플라이',
      'subtitle': '가슴, 어깨',
      'image': 'assets/chest/cable-fly.png',
    },
    {
      'title': '케이블 하이 플라이',
      'subtitle': '가슴, 어깨',
      'image': 'assets/chest/cable-high-fly.png',
    },
    {
      'title': '케이블 로우 플라이',
      'subtitle': '가슴, 어깨',
      'image': 'assets/chest/cable-low-fly.png',
    },
    {
      'title': '케이블 인클라인 벤치 플라이',
      'subtitle': '가슴, 어깨',
      'image': 'assets/chest/incline-cable-fly.png',
    },
    {
      'title': '케이블 디클라인 벤치 플라이',
      'subtitle': '가슴, 어깨',
      'image': 'assets/chest/decline-cable-fly.png',
    },

    {
      'title': '푸시 업',
      'subtitle': '가슴, 어깨, 삼두',
      'image': 'assets/chest/push-up.png',
    },
    {
      'title': '중량 푸시 업',
      'subtitle': '가슴, 어깨, 삼두',
      'image': 'assets/chest/weighted-push-up.png',
    },

    {
      'title': '바벨 풀 오버',
      'subtitle': '가슴, 등',
      'image': 'assets/chest/barbell-pullover.png',
    },
    {
      'title': '덤벨 풀 오버',
      'subtitle': '가슴, 삼두',
      'image': 'assets/chest/dumbbell-pullover.png',
    },
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Training List'),
        automaticallyImplyLeading: false, // 뒤로 가기 버튼 삭제
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Image.asset(
              item['image']!,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            title: Text(item['title']!),
            subtitle: Text(item['subtitle']!),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // 여기에 아이콘 버튼 클릭 시 동작할 기능을 추가하세요
              },
            ),
          );
        },
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
                    await dbHelper.createRoutineTable(user['id'], input); // 사용자 ID 포함
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
