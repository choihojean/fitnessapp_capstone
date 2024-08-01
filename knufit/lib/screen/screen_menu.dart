import 'package:flutter/material.dart';
import 'profile_page.dart'; // ProfilePage를 import
import 'dart:io';

class ScreenMenu extends StatefulWidget {
  final Map<String, dynamic> user; // 로그인 정보를 받을 변수

  const ScreenMenu({required this.user, Key? key}) : super(key: key);

  @override
  _ScreenMenuState createState() => _ScreenMenuState();
}

class _ScreenMenuState extends State<ScreenMenu> {
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                '프로필',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final updatedUser = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(user: user), //현재 유저 정보를 ProfilePage로 전달
                    ),
                  );

                  if (updatedUser != null) {
                    setState(() {
                      user = updatedUser; //null이 아닐 경우 유저 정보 갱신
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8.0), // 클릭 가능한 영역 확장
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        backgroundImage: user['profile_image'] != null
                            ? FileImage(File(user['profile_image'])) as ImageProvider
                            : AssetImage('assets/profile_default.jpg'),
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'],
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user['email'],
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 다른 기능들을 추가할 공간
            ],
          ),
        ),
      ),
    );
  }
}
