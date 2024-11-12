// screen_routine_table.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수 로드
import 'package:http/http.dart' as http;
import '../../trainingdetail_model.dart';

class ScreenRoutineTable extends StatefulWidget {
  final String tableName; // 클릭된 테이블 이름
  final Map<String, dynamic> user; // 사용자 정보를 받을 변수
  final int trainingListId; // 루틴 ID 추가

  ScreenRoutineTable({
    required this.tableName,
    required this.user,
    required this.trainingListId, // 생성자에 추가
    Key? key,
  }) : super(key: key);

  @override
  _ScreenRoutineTableState createState() => _ScreenRoutineTableState();
}

class _ScreenRoutineTableState extends State<ScreenRoutineTable> {
  List<TrainingDetailItem> trainingDetailItems = [];
  final String? serverIp = dotenv.env['SERVER_IP'];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRoutineTableData();
  }

  @override
  void dispose() {
    // 필요한 경우 여기에서 타이머, 스트림 등을 취소합니다.
    super.dispose();
  }

  // 루틴에 저장된 운동 목록 불러오기 trainingdetail get
  Future<void> _loadRoutineTableData() async {
    if (serverIp == null) {
      if (!mounted) return;
      setState(() {
        _error = 'SERVER_IP가 .env 파일에 정의되어 있지 않습니다.';
        _isLoading = false;
      });
      return;
    }

    final Uri uri = Uri.parse('http://$serverIp/traininglistdetail').replace(queryParameters: {
      'userid': '${widget.user['id']}',
      'traininglistid': '${widget.trainingListId}',
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        if (!mounted) return;
        setState(() {
          trainingDetailItems = jsonData.map((json) => TrainingDetailItem.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운동 목록을 불러오는 데 실패했습니다.')),
        );
        setState(() {
          _error = '운동 목록을 불러오는 데 실패했습니다: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('에러 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('운동 목록을 불러오는 중 오류가 발생했습니다.')),
      );
      setState(() {
        _error = '에러 발생: $e';
        _isLoading = false;
      });
    }
  }

  // 운동 삭제 trainingdetail delete
  Future<void> _deleteRoutineItem(int id) async {
    if (serverIp == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SERVER_IP가 .env 파일에 정의되어 있지 않습니다.')),
      );
      return;
    }

    final Uri uri = Uri.parse('http://$serverIp/traininglistdetail').replace(queryParameters: {
      'id': '$id', // traininglistdetail id 값
      'userid': '${widget.user['id']}',
    });

    try {
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운동이 루틴에서 삭제되었습니다.')),
        );
        _loadRoutineTableData(); // 목록 갱신
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운동 삭제에 실패했습니다.')),
        );
        print('삭제 요청 실패: ${response.statusCode}');
        print('응답 내용: ${response.body}');
      }
    } catch (e) {
      print('에러 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('운동 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  // 운동 메모 업데이트 trainingdetail put
  Future<void> _updateMemo(int id, String newContent) async {
    if (serverIp == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SERVER_IP가 .env 파일에 정의되어 있지 않습니다.')),
      );
      return;
    }

    final Uri uri = Uri.parse('http://$serverIp/traininglistdetail');

    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": id, // traininglistdetail id 값
          "user_id": '${widget.user['id']}',
          "content": newContent, // 변경된 운동 메모
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운동 메모가 업데이트되었습니다.')),
        );
        _loadRoutineTableData(); // 목록 갱신
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운동 메모 업데이트에 실패했습니다.')),
        );
        print('업데이트 요청 실패: ${response.statusCode}');
        print('응답 내용: ${response.body}');
      }
    } catch (e) {
      print('에러 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('운동 메모 업데이트 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maintheme = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tableName}'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.save),
          //   onPressed: () {
          //     // 저장 버튼의 기능을 구현하세요 (예: 전체 메모 저장 등)
          //   },
          // ),
          // IconButton(
          //   icon: Icon(Icons.delete),
          //   onPressed: () async {
          //     bool? confirmed = await showDialog(
          //       context: context,
          //       builder: (context) {
          //         return AlertDialog(
          //           title: Text('루틴 삭제'),
          //           content: Text('이 루틴을 정말 삭제하시겠습니까?'),
          //           actions: [
          //             TextButton(
          //               onPressed: () => Navigator.of(context).pop(false),
          //               child: Text('취소'),
          //             ),
          //             TextButton(
          //               onPressed: () => Navigator.of(context).pop(true),
          //               child: Text('삭제'),
          //             ),
          //           ],
          //         );
          //       },
          //     );

          //     if (confirmed == true) {
          //       // 루틴 삭제 로직을 구현하세요
          //       // 예: 별도의 delete 루틴 API 호출
          //       Navigator.of(context).pop(true); // 삭제 후 true 반환
          //     }
          //   },
          // ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : trainingDetailItems.isEmpty
                  ? Center(child: Text('루틴에 추가된 운동이 없습니다.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: trainingDetailItems.length,
                      itemBuilder: (context, index) {
                        final item = trainingDetailItems[index];
                        return Card(
                          key: ValueKey(item.trainingListDetail.id),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading: Image.network(
                              item.training.img,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image, size: 50);
                              },
                            ),
                            title: Text(item.training.name),
                            subtitle: Text(item.trainingListDetail.content),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: maintheme),
                              onPressed: () async {
                                bool? confirmed = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('운동 삭제'),
                                      content: Text('이 운동을 루틴에서 삭제하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text('취소'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text('삭제'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmed == true) {
                                  _deleteRoutineItem(item.trainingListDetail.id);
                                }
                              },
                            ),
                            onTap: () {
                              // 운동 메모 업데이트 또는 상세 보기 기능을 추가할 수 있습니다
                              _showMemoDialog(item.trainingListDetail.id, item.trainingListDetail.content);
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  // 운동 메모 업데이트 다이얼로그
  Future<void> _showMemoDialog(int id, String currentContent) async {
    final TextEditingController _memoController = TextEditingController(text: currentContent);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('운동 메모 수정'),
          content: TextField(
            controller: _memoController,
            decoration: InputDecoration(
              hintText: '운동 메모를 입력하세요',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                String newContent = _memoController.text.trim();
                if (newContent.isNotEmpty) {
                  _updateMemo(id, newContent);
                  Navigator.of(context).pop();
                }
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import '../../database/db_helper.dart'; // DBHelper 클래스를 import

// class ScreenRoutineTable extends StatefulWidget {
//   final String tableName; // 클릭된 테이블 이름
//   final Map<String, dynamic> user; // 사용자 정보를 받을 변수

//   ScreenRoutineTable({required this.tableName, required this.user, Key? key}) : super(key: key);

//   @override
//   _ScreenRoutineTableState createState() => _ScreenRoutineTableState();
// }

// class _ScreenRoutineTableState extends State<ScreenRoutineTable> {
//   List<Map<String, dynamic>> data = [];
//   final dbHelper = DBHelper();

//   @override
//   void initState() {
//     super.initState();
//     _loadRoutineTableData();
//   }

//   Future<void> _loadRoutineTableData() async {
//     final loadedData = await dbHelper.getRoutineTableData(widget.user['id'], widget.tableName);
//     setState(() {
//       // 각 Map 객체를 수정 가능하도록 복사
//       data = List<Map<String, dynamic>>.from(loadedData.map((item) => Map<String, dynamic>.from(item)));
//     });
//   }

//   Future<void> _deleteRoutineItem(int id) async {
//     await dbHelper.deleteRoutineItem(widget.tableName, id);
//     _loadRoutineTableData(); // 삭제 후 목록 갱신
//   }

//   Future<void> _updateMemo(int index, String newMemo) async {
//     setState(() {
//       data[index]['memo'] = newMemo;
//     });

//     // 데이터베이스에 메모 업데이트
//     await dbHelper.updateRoutineMemo(widget.tableName, data[index]['id'], newMemo);
//   }

//   Future<void> _updateOrder() async {
//     for (int i = 0; i < data.length; i++) {
//       await dbHelper.updateRoutineOrder(widget.tableName, data[i]['id'], i);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.tableName}'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: () async {
//               // 메모 수정 및 저장 로직
//               for (int i = 0; i < data.length; i++) {
//                 await _updateMemo(i, data[i]['memo']);
//               }
//               await _updateOrder();  // 변경된 순서 저장
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('변경된 메모와 순서가 저장되었습니다.')),
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.delete),
//             onPressed: () async {
//               bool? confirmed = await showDialog(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: Text('루틴 삭제'),
//                     content: Text('이 루틴을 정말 삭제하시겠습니까?'),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(false),
//                         child: Text('취소'),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(true),
//                         child: Text('삭제'),
//                       ),
//                     ],
//                   );
//                 },
//               );

//               if (confirmed == true) {
//                 await dbHelper.deleteRoutineTable(
//                     widget.user['id'], widget.tableName);
//                 Navigator.of(context).pop(true); // 삭제 후 true 반환
//               }
//             },
//           ),
//         ],
//       ),
//       body: ReorderableListView.builder(
//         itemCount: data.length,
//         onReorder: (int oldIndex, int newIndex) {
//           setState(() {
//             if (newIndex > oldIndex) {
//               newIndex -= 1;
//             }
//             final item = data.removeAt(oldIndex);
//             data.insert(newIndex, item);
//           });
//         },
//         itemBuilder: (context, index) {
//           final item = data[index];
//           final TextEditingController memoController = TextEditingController(text: item['memo']);

//           return Stack(
//             key: ValueKey(item['id']),
//             children: [
//               Column(
//                 children: [
//                   ListTile(
//                     leading: Image.asset(
//                       item['image']!,
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.contain,
//                     ),
//                     title: Text(item['title']!),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           item['content']!,
//                           style: TextStyle(
//                             color: Colors.grey.withOpacity(0.9), // subtitle의 투명도 설정
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         TextField(
//                           controller: memoController,
//                           decoration: InputDecoration(
//                             hintText: '메모를 입력하세요',
//                             border: OutlineInputBorder(),
//                           ),
//                           onChanged: (newValue) {
//                             data[index]['memo'] = newValue;
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   Divider(), // 항목 간의 구분선을 추가
//                 ],
//               ),
//               Positioned(
//                 right: 8,
//                 top: 8,
//                 child: IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () async {
//                     bool? confirmed = await showDialog(
//                       context: context,
//                       builder: (context) {
//                         return AlertDialog(
//                           title: Text('운동 삭제'),
//                           content: Text('이 운동을 정말 삭제하시겠습니까?'),
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(false),
//                               child: Text('취소'),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(true),
//                               child: Text('삭제'),
//                             ),
//                           ],
//                         );
//                       },
//                     );

//                     if (confirmed == true) {
//                       await _deleteRoutineItem(item['id']);
//                     }
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
