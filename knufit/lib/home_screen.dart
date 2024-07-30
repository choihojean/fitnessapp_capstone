import 'package:flutter/material.dart';
import 'screen/screen_home.dart';
import 'screen/screen_training_list.dart';
import 'screen/screen_calendar.dart';
import 'screen/screen_menu.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user; // 로그인 정보를 받을 변수

  const HomeScreen({required this.user, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    ScreenHome(),
    ScreenTrainingList(),
    ScreenCalendar(),
    ScreenMenu(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('안녕하세요, ${widget.user['name']}님'), // 로그인한 사용자의 이름 표시
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Training',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // 선택된 아이템 색상 설정
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상 설정
        onTap: _onItemTapped,
      ),
    );
  }
}
