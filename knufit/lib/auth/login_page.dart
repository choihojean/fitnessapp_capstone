import 'dart:convert';
import 'package:flutter/material.dart';
import '../home_screen.dart';
import 'auth_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
  String email = _emailController.text;
  String password = _passwordController.text;
  final serverIp = dotenv.env['SERVER_IP'];
  var user;

  if (email.isNotEmpty && password.isNotEmpty && serverIp != null) {
    final url = Uri.parse('$serverIp/user/login');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(res.bodyBytes));
        user = responseData;

        // 모든 사용자 정보 저장
        await AuthHelper.saveUserSession(user);

        // HomeScreen으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(user: user),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('이메일과 비밀번호를 입력해주세요')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// //import '../database/db_helper.dart';
// import '../home_screen.dart';
// import 'auth_helper.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   //final DBHelper _dbHelper = DBHelper();

//   void _login() async {
//     String email = _emailController.text;
//     String password = _passwordController.text;
//     final FastAPI = dotenv.env['SERVER_IP'];
//     var user;

//     if (email.isNotEmpty && password.isNotEmpty) {
//       // var user = await _dbHelper.getUser(email, password);
//       final url = Uri.parse('${FastAPI}/user/login');
//         try {
//           final res = await http.post(
//             url,
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               'email': email,
//               'password':password
//             }));
//             if (res.statusCode == 200) {
//               final responseData = jsonDecode(utf8.decode(res.bodyBytes));
//               print('응답 데이터: $responseData');
//               user = responseData;
//             } else {
//               print('요청 실패: ${res.statusCode}');
//               print('응답 내용: ${res.body}');
//             }
//         } catch (e) {
//           print('에러 발생: $e');
//         }
//       if (user != null) {
//         await AuthHelper.saveUserSession(user);
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('성공적으로 로그인 되었습니다')),
//         );
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HomeScreen(user: user), // 로그인 정보를 전달
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Email이나 비밀번호가 잘못되었습니다')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('입력하지 않은 정보가 존재합니다')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('로그인')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               keyboardType: TextInputType.emailAddress,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: '비밀번호'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _login,
//               child: Text('로그인'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
