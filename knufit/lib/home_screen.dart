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
  late Map<String, dynamic> user;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _widgetOptions = <Widget>[
      ScreenHome(user: user), // 로그인 정보를 전달
      ScreenTrainingList(),
      ScreenCalendar(user: user),
      ScreenMenu(user: user), // 로그인 정보를 전달
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('안녕하세요, ${user['name']}님'), // 로그인한 사용자의 이름 표시
      // ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
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
