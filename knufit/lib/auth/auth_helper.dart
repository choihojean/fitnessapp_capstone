import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../screen/change_password_page.dart';

class AuthHelper {
  // 로그아웃 처리
  static Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // 모든 사용자 정보 삭제
    await prefs.clear(); // clear()로 모든 SharedPreferences 데이터 제거
    
    // 로그아웃 후 초기 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FitnessApp()),
    );
  }

  // 사용자 세션 저장
  static Future<void> saveUserSession(Map<String, dynamic> user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // 사용자 정보 저장
    await prefs.setInt('user_id', user['id']);
    await prefs.setString('user_email', user['email']);
    await prefs.setString('user_name', user['name']);
    
    if (user['profile_image'] != null && user['profile_image']!.isNotEmpty) {
      await prefs.setString('user_profile_image', user['profile_image']);
    } else {
      await prefs.remove('user_profile_image'); // 프로필 이미지가 없으면 삭제
    }
  }

  // 사용자 세션 조회
  static Future<Map<String, dynamic>?> getUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey('user_id')) {
      return null;
    }

    // 각 필드가 null이면 기본값 설정
    return {
      'id': prefs.getInt('user_id'),
      'email': prefs.getString('user_email') ?? '',
      'name': prefs.getString('user_name') ?? '',
      'profile_image': prefs.getString('user_profile_image') ?? '',
    };
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
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                logout(context); // 로그아웃 실행
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 비밀번호 변경 페이지로 이동
  static void changePassword(BuildContext context, Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordPage(user: user)),
    );
  }
}
