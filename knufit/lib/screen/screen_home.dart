import 'package:flutter/material.dart';
import 'home_screen/screen_home_memo.dart';
import 'home_screen/screen_routine.dart';

class ScreenHome extends StatefulWidget {
  @override
  _ScreenHomeState createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  int _selectedTabIndex = 0;

  final List<Widget> _screens = [
    ScreenHomeMemo(),
    ScreenRoutine(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KNU Fit'),
        //backgroundColor: Color.fromARGB(255, 163, 163, 163), // 투명한 파란색 배경
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _onTabSelected(0),
                child: Text(
                  'Home Memo',
                  style: TextStyle(
                    color: _selectedTabIndex == 0 ? Colors.blue : const Color.fromARGB(179, 41, 41, 41),
                    fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _onTabSelected(1),
                child: Text(
                  'Routine',
                  style: TextStyle(
                    color: _selectedTabIndex == 1 ? Colors.blue : const Color.fromARGB(179, 41, 41, 41),
                    fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
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
