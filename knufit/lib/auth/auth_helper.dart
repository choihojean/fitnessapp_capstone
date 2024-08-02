import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../screen/change_password_page.dart';

class AuthHelper {
  static Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_profile_image');
    
    // 로그아웃 처리
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FitnessApp()),
    );
  }

  static Future<void> saveUserSession(Map<String, dynamic> user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user['id']);
    await prefs.setString('user_email', user['email']);
    await prefs.setString('user_name', user['name']);
    if (user['profile_image'] != null) {
      await prefs.setString('user_profile_image', user['profile_image']);
    }
  }

  static Future<Map<String, dynamic>?> getUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_id')) {
      return null;
    }

    return {
      'id': prefs.getInt('user_id'),
      'email': prefs.getString('user_email'),
      'name': prefs.getString('user_name'),
      'profile_image': prefs.getString('user_profile_image'),
    };
  }

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
                Navigator.of(context).pop(); // 대화상자 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
                logout(context); // 로그아웃 실행
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
  
  static void changePassword(BuildContext context, Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordPage(user: user)),
    );
  }
}


