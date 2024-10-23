import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수 로드
import 'package:http/http.dart' as http;

/// ScreenMemo는 메모를 생성하거나 수정할 수 있는 화면입니다.
class ScreenMemo extends StatefulWidget {
  /// 사용자 정보를 담고 있는 맵. 예: {'id': 1, 'name': 'John Doe'}
  final Map<String, dynamic> user;

  /// 수정할 메모 정보. 새 메모를 생성할 때는 null로 설정됩니다.
  final Map<String, dynamic>? memo;

  /// ScreenMemo 위젯을 생성할 때 사용자 정보와 선택적으로 메모 정보를 받습니다.
  const ScreenMemo({required this.user, this.memo, Key? key}) : super(key: key);

  @override
  _ScreenMemoState createState() => _ScreenMemoState();
}

class _ScreenMemoState extends State<ScreenMemo> {
  /// 제목 입력을 위한 컨트롤러
  final TextEditingController _titleController = TextEditingController();

  /// 내용 입력을 위한 컨트롤러
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    /// 수정 모드일 경우 기존 메모의 제목과 내용을 컨트롤러에 설정
    if (widget.memo != null) {
      _titleController.text = widget.memo!['title'];
      _contentController.text = widget.memo!['content'];
    }
  }

  /// 메모를 저장하거나 업데이트하는 함수
  void _saveMemo(int userId) async {
    String title = _titleController.text.trim();
    String content = _contentController.text.trim();
    final String? serverIp = dotenv.env['SERVER_IP'];

    /// SERVER_IP가 설정되어 있지 않으면 예외를 던집니다.
    if (serverIp == null) {
      throw Exception('SERVER_IP is not defined in .env file');
    }

    /// 요청할 URI를 구성합니다.
    final uri = Uri.parse('$serverIp/memo');
    print('Request URI: $uri'); // 디버깅을 위해 요청 URI 출력

    /// 제목이나 내용이 비어있을 경우 사용자에게 알림
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 내용을 모두 입력하세요.')),
      );
      return;
    }

    try {
      http.Response response;

      /// 메모가 존재하지 않으면 새 메모를 생성 (POST), 존재하면 메모를 수정 (PUT)
      if (widget.memo == null) {
        // 새 메모 생성
        response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'title': title,
            'content': content,
          }),
        );
      } else {
        // 기존 메모 수정
        final int memoId = widget.memo!['id'];
        final Uri updateUri = Uri.parse('$serverIp/memo');
        response = await http.put(
          updateUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id':memoId,
            'user_id':userId,
            'title': title,
            'content': content,
          }),
        );
      }

      /// 요청이 성공적이라면 (HTTP 200 또는 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.memo == null ? '메모가 저장되었습니다.' : '메모가 수정되었습니다.')),
        );
        Navigator.pop(context, true); // 변경 사항이 생겼음을 알림
      } else {
        /// 요청이 실패한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메모 저장에 실패했습니다.')),
        );
        print('요청 실패: ${response.statusCode}');
        print('응답 내용: ${response.body}');
      }
    } catch (e) {
      /// 네트워크 오류나 기타 예외 발생 시
      print('에러 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메모 저장 중 오류가 발생했습니다.')),
      );
    }
  }

  /// 메모를 삭제하는 함수
  void _deleteMemo() async {
    if (widget.memo == null) return; // 삭제할 메모가 없으면 종료

    final String? serverIp = dotenv.env['SERVER_IP'];
    if (serverIp == null) {
      throw Exception('SERVER_IP is not defined in .env file');
    }

    /// 삭제할 메모의 URI를 구성합니다.
    final int userId = widget.user['id'];
    final int memoId = widget.memo!['id'];
    final Uri deleteUri = Uri.parse('$serverIp/memo').replace(queryParameters: {
      'userid': '$userId',
      'id': '$memoId',
    });
    print('Delete URI: $deleteUri'); // 디버깅을 위해 삭제 URI 출력

    try {
      /// DELETE 요청을 서버에 보냅니다.
      final response = await http.delete(deleteUri);

      /// 요청이 성공적이라면 (HTTP 200 또는 204)
      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메모가 삭제되었습니다.')),
        );
        Navigator.pop(context, true); // 변경 사항이 생겼음을 알림
      } else {
        /// 삭제 요청이 실패한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('메모 삭제에 실패했습니다.')),
        );
        print('삭제 요청 실패: ${response.statusCode}');
        print('응답 내용: ${response.body}');
      }
    } catch (e) {
      /// 네트워크 오류나 기타 예외 발생 시
      print('삭제 에러 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메모 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.memo == null ? '새 메모' : '메모 수정'), // 메모 생성 또는 수정에 따라 제목 변경
        actions: [
          if (widget.memo != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteMemo, // 삭제 버튼 눌렀을 때 삭제 함수 호출
              tooltip: '메모 삭제',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 제목 입력 필드
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            SizedBox(height: 20),
            /// 내용 입력 필드
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: '내용'),
                maxLines: null,
                expands: true,
              ),
            ),
            /// 저장 버튼
            ElevatedButton(
              onPressed: () => _saveMemo(widget.user['id']), // 저장 버튼 눌렀을 때 저장 함수 호출
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../../database/db_helper.dart';

// class ScreenMemo extends StatefulWidget {
//   final Map<String, dynamic> user;
//   final Map<String, dynamic>? memo;

//   const ScreenMemo({required this.user, this.memo, Key? key}) : super(key: key);

//   @override
//   _ScreenMemoState createState() => _ScreenMemoState();
// }

// class _ScreenMemoState extends State<ScreenMemo> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     if (widget.memo != null) {
//       _titleController.text = widget.memo!['title'];
//       _contentController.text = widget.memo!['content'];
//     }
//   }

//   void _saveMemo() async {
//     String title = _titleController.text;
//     String content = _contentController.text;

//     if (title.isEmpty || content.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('제목과 내용을 모두 입력하세요.')),
//       );
//       return;
//     }

//     if (widget.memo == null) {
//       await DBHelper().insertMemo({
//         'userId': widget.user['id'],
//         'title': title,
//         'content': content,
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('메모가 저장되었습니다.')),
//       );
//     } else {
//       await DBHelper().updateMemo({
//         'id': widget.memo!['id'],
//         'title': title,
//         'content': content,
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('메모가 수정되었습니다.')),
//       );
//     }

//     Navigator.pop(context, true); // 변경 사항이 생겼음을 알림
//   }

//   void _deleteMemo() async {
//     if (widget.memo != null) {
//       await DBHelper().deleteMemo(widget.memo!['id']);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('메모가 삭제되었습니다.')),
//       );
//       Navigator.pop(context, true); // 메모 삭제 후 변경 사항 알림
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.memo == null ? '새 메모' : '메모 수정'),
//         actions: [
//           if (widget.memo != null)
//             IconButton(
//               icon: Icon(Icons.delete),
//               onPressed: _deleteMemo,
//               tooltip: '메모 삭제',
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(labelText: '제목'),
//             ),
//             SizedBox(height: 20),
//             Expanded(
//               child: TextField(
//                 controller: _contentController,
//                 decoration: InputDecoration(labelText: '내용'),
//                 maxLines: null,
//                 expands: true,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _saveMemo,
//               child: Text('저장'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
