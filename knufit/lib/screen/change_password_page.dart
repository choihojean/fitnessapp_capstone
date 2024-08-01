import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../utils/utils.dart'; // hashPassword 함수를 사용하기 위해 import

class ChangePasswordPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChangePasswordPage({required this.user, Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();

  void _changePassword() async {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmNewPassword = _confirmNewPasswordController.text;

    if (newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('새 비밀번호가 일치하지 않습니다')),
      );
      return;
    }

    var user = await _dbHelper.getUser(widget.user['email'], oldPassword);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기존 비밀번호가 잘못되었습니다')),
      );
      return;
    }

    Map<String, dynamic> updatedUser = {
      'id': widget.user['id'],
      'email': widget.user['email'],
      'name': widget.user['name'],
      'password': hashPassword(newPassword), // 비밀번호 해시화하여 저장
      'profile_image': widget.user['profile_image']
    };

    await _dbHelper.updateUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('비밀번호가 변경되었습니다')),
    );

    Navigator.pop(context, updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _oldPasswordController,
              decoration: InputDecoration(labelText: '기존 비밀번호'),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: '새 비밀번호'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmNewPasswordController,
              decoration: InputDecoration(labelText: '새 비밀번호 확인'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('비밀번호 변경'),
            ),
          ],
        ),
      ),
    );
  }
}
