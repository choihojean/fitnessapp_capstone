import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final String? serverIP = dotenv.env['SERVER_IP'];

Future<bool> checkServerIP() async {
  return serverIP != null;
}

Future<String> typeDateToString(DateTime date) async{
  return DateFormat('yyyy-MM-dd').format(date);
}

// datememo 전체 read
Future<List<Map<String, dynamic>>> readDateMemosAllServer(int userId) async {
  List<Map<String, dynamic>> datememos = [];
  final uri = Uri.http('$serverIP', '/datememo', {"userid" : userId.toString()});
  //final userIdStr = userId.toString();
  try {
    final response = await http.get(uri);
    print(response.body);
    //final List<Map<String, dynamic>> resData = jsonDecode(utf8.decode(response.bodyBytes));
    final List<Map<String, dynamic>> resData = List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    print('데이터 ========= $resData');
    datememos = resData;
  } catch(e) {
    print({"error": e});
  }
  return datememos;
}

// datememo create
Future<void> createDateMemo(int userId, DateTime date, String title, String content) async {
  final uri = Uri.http('$serverIP', '/datememo');
  //final uri = Uri.parse('$serverIP/datememo');
  final dateStr = await typeDateToString(date);
  print('$userId == $date == $title == $content');
  if(title.isEmpty) title = dateStr;
  try {
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "user_id": userId,
        "title": title,
        "content": content,
        "datetime": dateStr
      })
    );
    print(response.statusCode);
  } catch(e) {
    print({"error": e});
  }
}

// datememo update
Future<void> updateDateMemo(Map<String, dynamic> dateMemo, String title, String content) async {
  final uri = Uri.http('$serverIP', '/datememo');
  //final uri = Uri.parse('$serverIP/datememo');
  if(title.isEmpty) title = dateMemo["datetime"];
  try {
    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": dateMemo["id"],
        "user_id": dateMemo["user_id"],
        "title": title,
        "content": content,
      })
    );
    print(response.statusCode);
  } catch(e) {
    print({"error": e});
  }
}

// datememo delete
Future<void> deleteDateMemo(int dateMemoId, int userId) async {
  final uri = Uri.http('$serverIP', '/datememo', {"id" : dateMemoId.toString(), "userid" : userId.toString()});
  //final uri = Uri.parse('$serverIP/datememo?id=$dateMemoId&userid=$userId');
  try {
    final response = await http.delete(uri);
    print(response.statusCode);
  } catch(e) {
    print({"error": e});
  }
}