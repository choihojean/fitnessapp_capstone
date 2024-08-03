import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_page.dart'; // ProfilePage를 import
import '../auth/auth_helper.dart';
import '../theme_notifier.dart';
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

  //메뉴 옵션
  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: TextStyle(color: Colors.orange)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메뉴'),
        automaticallyImplyLeading: false, //뒤로가기 버튼 제거
      ),
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
              Divider(color: Colors.black),
              _buildMenuOption(Icons.logout, '로그아웃', () {
                AuthHelper.confirmLogout(context);
              }), //로그아웃 메뉴
              _buildMenuOption(Icons.password, '비밀번호 변경', (){
                AuthHelper.changePassword(context, user);
              }), //비밀번호 변경
              SwitchListTile(
                title: Text("다크 모드", style: TextStyle(color: Colors.orange)),
                value: Provider.of<ThemeNotifier>(context).isDarkMode,
                onChanged: (value) {
                  Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                },
                secondary: Icon(Icons.brightness_6, color: Colors.orange),
                activeColor: Colors.deepOrangeAccent,
                activeTrackColor: Colors.orange,
              ),
              // 다른 기능들을 추가할 공간
            ],
          ),
        ),
      ),
    );
  }
}
