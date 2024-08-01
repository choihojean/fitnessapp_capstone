import 'package:flutter/material.dart';
import '../main.dart';
import '../screen/change_password_page.dart';

class AuthHelper {
  static void logout(BuildContext context) {
    // 로그아웃 처리
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FitnessApp()),
    );
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


