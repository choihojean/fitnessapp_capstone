import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../utils/utils.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();

  bool _isPasswordValid = false;
  bool _isPasswordMatch = false;
  bool _hasUppercase = false;
  bool _hasDigits = false;
  bool _hasSpecialCharacters = false;
  bool _hasValidLength = false;

  void _signup() async {
    String email = _emailController.text;
    String name = _nameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (email.isNotEmpty && name.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty) {
      if (!isValidEmail(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('유효한 이메일 주소를 입력하세요.')),
        );
        return;
      }

      if (!_isPasswordValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호는 유효하지 않습니다.')),
        );
        return;
      }

      // 이메일 중복 확인 로직 추가
      var existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 가입된 이메일 주소입니다.')),
        );
        return;
      }

      if (password == confirmPassword) {
        await _dbHelper.insertUser({
          'email': email,
          'name': name,
          'password':password,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입을 환영합니다!')),
        );

        Navigator.pop(context); // 로그인 페이지로 돌아가기
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 동일하지 않습니다.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 공간을 작성해주세요.')),
      );
    }
  }

  void _validatePassword(String password) {
    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Za-z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasValidLength = password.length >= 6 && password.length < 20;

      _isPasswordValid = _hasUppercase && _hasDigits && _hasSpecialCharacters && _hasValidLength;
      _isPasswordMatch = password == _confirmPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '성함'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
              onChanged: _validatePassword,
            ),
            _buildPasswordCriteria(), // 비밀번호 조건 표시
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: '비밀번호 확인'),
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _isPasswordMatch = value == _passwordController.text;
                });
              },
            ),
            _buildPasswordMatchCriteria(), // 비밀번호 일치 여부 표시
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPasswordValid && _isPasswordMatch ? _signup : null,
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCriteria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildCriteriaRow('영문', _hasUppercase),
            SizedBox(width: 8),
            _buildCriteriaRow('숫자', _hasDigits),
            SizedBox(width: 8),
            _buildCriteriaRow('특수문자', _hasSpecialCharacters),
            SizedBox(width: 8),
            _buildCriteriaRow('6-20자 이내', _hasValidLength),
          ],
        ),
        
      ],
    );
  }

  Widget _buildPasswordMatchCriteria() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCriteriaRow('비밀번호 일치', _isPasswordMatch),
      ],
    );
  }

  Widget _buildCriteriaRow(String criteria, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check : Icons.check,
          color: isValid ? Colors.orange : Colors.grey,
        ),
        SizedBox(width: 10),
        Text(criteria, style: TextStyle(color: isValid ? Colors.orange : Colors.grey)),
      ],
    );
  }
}
