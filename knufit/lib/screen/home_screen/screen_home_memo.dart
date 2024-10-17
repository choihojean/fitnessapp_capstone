import 'dart:convert';
import 'package:flutter/material.dart';
// import '../../database/db_helper.dart'; // 필요 시 주석 해제
import 'screen_memo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ScreenHomeMemo extends StatefulWidget {
  final Map<String, dynamic> user;

  const ScreenHomeMemo({required this.user, Key? key}) : super(key: key);

  @override
  _ScreenHomeMemoState createState() => _ScreenHomeMemoState();
}

class _ScreenHomeMemoState extends State<ScreenHomeMemo> {
  late Future<List<Map<String, dynamic>>> _memos;

  // 서버 IP를 환경 변수에서 불러옵니다.
  final String? serverIp = dotenv.env['SERVER_IP'];

  @override
  void initState() {
    super.initState();
    _memos = _fetchMemos(widget.user['id']);
  }

  Future<List<Map<String, dynamic>>> _fetchMemos(int userId) async {
    if (serverIp == null) {
      throw Exception('SERVER_IP is not defined in .env file');
    }

    final baseurl = '$serverIp/memo'; // 엔드포인트를 '/memo'로 수정
    final Map<String, String> queryParams = {
      'userid': userId.toString(), // 쿼리 파라미터 이름을 'userid'로 수정
    };
    final uri = Uri.parse(baseurl).replace(queryParameters: queryParams);

    print('Request URI: $uri'); // 디버깅을 위해 요청 URI 출력

    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(res.body);
        // 각 메모를 Map<String, dynamic>으로 변환
        List<Map<String, dynamic>> memos =
            responseData.map((memo) => memo as Map<String, dynamic>).toList();
        print('응답 데이터: ${memos}');
        return memos;
      } else {
        print('요청 실패: ${res.statusCode}');
        print('응답 내용: ${res.body}');
        return [];
      }
    } catch (e) {
      print('에러 발생: $e');
      throw Exception('Failed to load memos');
    }
  }

  void _reloadMemos() {
    setState(() {
      _memos = _fetchMemos(widget.user['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('메모 리스트'),
      // ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _memos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('저장된 메모가 없습니다.'));
          } else {
            List<Map<String, dynamic>> memos = snapshot.data!;
            return ListView.separated(
              itemCount: memos.length,
              separatorBuilder: (context, index) => Divider(), // 메모 간 구분선 추가
              itemBuilder: (context, index) {
                final memo = memos[index];
                return ListTile(
                  title: Text(memo['title']),
                  subtitle: Text(
                    memo['content'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenMemo(
                          user: widget.user,
                          memo: memo,
                        ),
                      ),
                    );
                    if (result == true) _reloadMemos(); // 수정 후 목록 갱신
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'homeMemo',
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenMemo(user: widget.user),
            ),
          );
          if (result == true) _reloadMemos(); // 추가 후 목록 갱신
        },
        child: Icon(Icons.add),
        tooltip: '새 메모 추가',
      ),
    );
  }
}
