import 'package:flutter/material.dart';
import 'home_screen/screen_home_memo.dart';
import 'home_screen/screen_routine.dart';

class ScreenHome extends StatefulWidget {
  final Map<String, dynamic> user; // 로그인 정보를 받을 변수

  const ScreenHome({required this.user, Key? key}) : super(key: key);

  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 사용자 정보를 화면에 전달
    final List<Widget> _screens = [
      ScreenHomeMemo(user: widget.user), // 사용자 정보를 전달
      ScreenRoutine(), // 사용자 정보를 전달
    ];

    void _onTabSelected(int index) {
      setState(() {
        _selectedTabIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KNU Fit'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _onTabSelected(0),
                  child: Text(
                    'Home Memo',
                    style: TextStyle(
                      color: _selectedTabIndex == 0 ? Colors.blue : const Color.fromARGB(179, 41, 41, 41),
                      fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => _onTabSelected(1),
                  child: Text(
                    'Routine',
                    style: TextStyle(
                      color: _selectedTabIndex == 1 ? Colors.blue : const Color.fromARGB(179, 41, 41, 41),
                      fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _screens[_selectedTabIndex],
    );
  }
}
