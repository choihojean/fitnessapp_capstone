import 'dart:convert';
import 'package:flutter/material.dart';
import 'screen_memo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ScreenHomeMemo extends StatefulWidget {
  /// 사용자 정보를 담고 있는 맵. 예: {'id': 1, 'name': 'John Doe'}
  final Map<String, dynamic> user;//위젯의 user 정보는 생성 시에만 설정되고 이후에 변경되지 않기 때문에, final로 선언하여 불변성을 보장
  const ScreenHomeMemo({required this.user, Key? key}) : super(key: key);

  @override
  _ScreenHomeMemoState createState() => _ScreenHomeMemoState();
}

class _ScreenHomeMemoState extends State<ScreenHomeMemo> {
  /// 메모 데이터를 비동기적으로 가져오기 위한 Future 객체
  late Future<List<dynamic>> _memosFuture;

  @override
  void initState() {
    super.initState();
    /// 화면이 초기화될 때 사용자 ID에 해당하는 메모 가져오기
    _memosFuture = _fetchMemos(widget.user['id']);
  }

  // 특정 사용자 ID에 해당하는 메모 목록을 서버에서 가져오는 비동기 함수
  Future<List<dynamic>> _fetchMemos(int userId) async {
    final String? serverIp = dotenv.env['SERVER_IP']; // ? = null 값 처리
    print("1 : $userId");

    // SERVER_IP가 정의되어 있지 않으면 예외처리
    if (serverIp == null) {
      throw Exception('SERVER_IP is not defined in .env file');
    }

    // URI를 구성
    final uri = Uri.parse('$serverIp/memo').replace(queryParameters: {'userid': '$userId'});
    print('Request URI: $uri'); // 디버깅을 위해 요청 URI를 출력

    try {
      // GET 요청
      final res = await http.get(uri);

      // 요청이 성공적이라면(HTTP 200) 응답 데이터를 파싱
      if (res.statusCode == 200) {
        final List<dynamic> memos = jsonDecode(utf8.decode(res.bodyBytes)); // JSON 응답을 파싱하여 List<dynamic>으로 변환
        print('응답 데이터: $memos'); 
        return memos; // 메모 목록을 반환합니다.
      } else {
        print('요청 실패: ${res.statusCode}');
        print('응답 내용: ${res.body}');
        return [];
      }
    } catch (e) {
      // 네트워크 오류나 기타 예외가 발생한 경우 에러 메시지를 출력하고 예외 처리
      print('에러 발생: $e');
      throw Exception('Failed to load memos');
    }
  }
  // 메모 목록을 다시 불러오는 함수
  void _reloadMemos() {
    setState(() {
      _memosFuture = _fetchMemos(widget.user['id']); // Future를 다시 초기화하여 재빌드를 유도
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('메모 리스트'),
      // ),
      body: FutureBuilder<List<dynamic>>(
        future: _memosFuture, // 비동기적으로 데이터를 가져오는 Future 객체를 지정
        builder: (context, snapshot) {
          // 데이터 로딩 중일 때 로딩 스피너를 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('저장된 메모가 없습니다.'));
          }
          // 데이터가 성공적으로 로드되었을 때 메모 목록을 표시합니다.
          else {
            final memos = snapshot.data!;
            return ListView.separated(
              itemCount: memos.length, // 메모 개수만큼 ListTile을 생성
              separatorBuilder: (context, index) => Divider(), // 메모 간 구분선을 추가
              itemBuilder: (context, index) {
                final memo = memos[index];
                return ListTile(
                  title: Text(memo['title']), // 메모의 제목을 표시
                  subtitle: Text(
                    memo['content'], // 메모의 내용을 한 줄로 표시
                    maxLines: 1, // 최대 1줄까지만 표시
                    overflow: TextOverflow.ellipsis, // 넘치는 텍스트는 말줄임표로 표시
                  ),
                  onTap: () async {
                    /// 메모를 탭하면 상세 화면으로 이동
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenMemo(
                          user: widget.user,
                          memo: memo,
                        ),
                      ),
                    );
                    /// 상세 화면에서 메모가 수정되었다면 목록을 다시 불러옴
                    if (result == true) _reloadMemos();
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'homeMemo', // FAB의 Hero 태그를 설정하여 애니메이션을 적용 가능
        onPressed: () async {
          // FAB를 누르면 새로운 메모를 추가할 수 있는 화면으로 이동
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenMemo(user: widget.user),
            ),
          );
          /// 메모가 추가되었다면 목록을 다시 불러오기
          if (result == true) _reloadMemos();
        },
        child: Icon(Icons.add),
        tooltip: '새 메모 추가',
      ),
    );
  }
}
// 기존코드
// import 'dart:convert';
// import 'package:flutter/material.dart';
// //import '../../database/db_helper.dart';
// import 'screen_memo.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;

// class ScreenHomeMemo extends StatefulWidget {
//   final Map<String, dynamic> user;

//   const ScreenHomeMemo({required this.user, Key? key}) : super(key: key);

//   @override
//   _ScreenHomeMemoState createState() => _ScreenHomeMemoState();
// }

// class _ScreenHomeMemoState extends State<ScreenHomeMemo> {
//   late Future<List<Map<String, dynamic>>> _memos;

  
//   final FastAPI = dotenv.env['SERVER_IP'];

//   @override
//   void initState() {
//     super.initState();
//     _loadMemos();
//   }
//   void _loadMemos() async{
//     final baseurl = '${FastAPI}/memo';
//     final Map<String, String> queryParams = {
//       'userid': '1',
//     };
//     final uri = Uri.parse(baseurl).replace(queryParameters: queryParams);
//         try {
//           final res = await http.get(uri);
//             if (res.statusCode == 200) {
//               final responseData = jsonDecode(res.body);
//               print('응답 데이터: $responseData');
//             } else {
//               print('요청 실패: ${res.statusCode}');
//               print('응답 내용: ${res.body}');
//             }
//         } catch (e) {
//           print('에러 발생: $e');
//         }
//      setState(() {
//        //_memos = DBHelper().getMemos(widget.user['id']);  //유저 정보에 따라 메모 가져오기
//      });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('메모 리스트'),
//       // ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _memos,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('저장된 메모가 없습니다.'));
//           } else {
//             List<Map<String, dynamic>> memos = snapshot.data!;
//             return ListView.builder(
//               itemCount: memos.length,
//               itemBuilder: (context, index) {
//                 final memo = memos[index];
//                 return Column(
//                   children: [
//                     ListTile(
//                       title: Text(memo['title']),
//                       subtitle: Text(
//                         memo['content'],
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       onTap: () async {
//                         bool? result = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ScreenMemo(
//                               user: widget.user,
//                               memo: memo,
//                             ),
//                           ),
//                         );
//                         if (result == true) _loadMemos(); // 수정 후 목록 갱신
//                       },
//                     ),
//                     Divider(), // 메모 간 구분선 추가
//                   ],
//                 );
//               },
//             );
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         heroTag: 'homeMemo',
//         onPressed: () async {
//           bool? result = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ScreenMemo(user: widget.user),
//             ),
//           );
//           if (result == true) _loadMemos(); // 추가 후 목록 갱신
//         },
//         child: Icon(Icons.add),
//         tooltip: '새 메모 추가',
//       ),
//     );
//   }
// } 