import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

final String? serverIP = dotenv.env['SERVER_IP'];

class AuthHelper {
  // 로그아웃 처리
  static Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 사용자 인증 정보 삭제
    await prefs.clear();

    // 로그아웃 후 초기 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FitnessApp()),
    );
  }

  // 사용자 세션 저장 (모든 사용자 정보 저장)
  static Future<void> saveUserSession(Map<String, dynamic> user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 사용자 정보 저장
    await prefs.setInt('user_id', user['id']);
    await prefs.setString('user_email', user['email']);
    await prefs.setString('user_password', user['password']);
    await prefs.setString('user_name', user['name'] ?? '');
    await prefs.setString('user_profile_img', user['profile_img'] ?? '');
    await prefs.setString('user_updated_at', user['updated_at'] ?? '');
    print("success!!!!");
  }

  // 사용자 세션 조회 (모든 사용자 정보 불러오기)
  static Future<Map<String, dynamic>?> getUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('user_id')) {
      return null;
    }

    final uri = Uri.http('$serverIP', '/user/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": prefs.getString('user_email'),
          "password": prefs.getString('user_password')
        })
      );
      final Map<String, dynamic> resData = Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
      print('res ========== $resData');
      
    } catch(e) {
      print({"error": e});
    }

    // 세션에서 모든 사용자 정보 불러오기
    return({
      'id': prefs.getInt('user_id'),
      'email': prefs.getString('user_email') ?? '',
      'password': prefs.getString('user_password') ?? '',
      'name': prefs.getString('user_name') ?? '',
      'profile_img': prefs.getString('user_profile_img') ?? '',
      'updated_at': prefs.getString('user_updated_at') ?? ''
    });
  }

  // 로그아웃 확인 다이얼로그
  static void confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                logout(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../main.dart';
// import '../screen/change_password_page.dart';

// class AuthHelper {
//   // 로그아웃 처리
//   static Future<void> logout(BuildContext context) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
    
//     // 사용자 인증 정보만 삭제
//     await prefs.remove('user_email');
//     await prefs.remove('user_password');
    
//     // 로그아웃 후 초기 화면으로 이동
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => FitnessApp()),
//     );
//   }

//   // 사용자 세션 저장
//   static Future<void> saveUserSession(Map<String, dynamic> user) async {  //정보 저장
//     SharedPreferences prefs = await SharedPreferences.getInstance();
    
//     // 사용자 정보 저장
//     await prefs.setString('user_email', user['email']);
//     await prefs.setString('user_password', user['password']);
    
//     // if (user['profile_image'] != null && user['profile_image']!.isNotEmpty) {
//     //   await prefs.setString('user_profile_image', user['profile_image']);
//     // } else {
//     //   await prefs.remove('user_profile_image'); // 프로필 이미지가 없으면 삭제
//     // }
//   }

//   // 사용자 세션 조회
//   static Future<Map<String, dynamic>?> getUserSession() async { // 로그인 정보를 자체적으로 저장해 두기
//     SharedPreferences prefs = await SharedPreferences.getInstance();
    
//     if (!prefs.containsKey('user_id')) {
//       return null;
//     }

//     // 각 필드가 null이면 기본값 설정
//     return {
//       // 'id': prefs.getInt('user_id'),
//       'email': prefs.getString('user_email') ?? '',
//       'password':prefs.getString('user_password') ?? '',
//       // 'name': prefs.getString('user_name') ?? '',
//       // 'profile_image': prefs.getString('user_profile_image') ?? '',
//     };
//   }

//   // 로그아웃 확인 다이얼로그
//   static void confirmLogout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('로그아웃'),
//           content: Text('로그아웃 하시겠습니까?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // 다이얼로그 닫기
//               },
//               child: Text('취소'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // 다이얼로그 닫기
//                 logout(context); // 로그아웃 실행
//               },
//               child: Text('확인'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // 비밀번호 변경 페이지로 이동
//   static void changePassword(BuildContext context, Map<String, dynamic> user) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ChangePasswordPage(user: user)),
//     );
//   }
// }
