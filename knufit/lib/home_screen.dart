import 'package:flutter/material.dart';
import 'package:knufit/screen/ai_screen/screen_ai.dart';
import 'screen/screen_home.dart';
import 'screen/screen_training_list.dart';
import 'screen/screen_calendar.dart';
import 'screen/screen_menu.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeScreen({required this.user, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Map<String, dynamic> user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ScreenHome(user: user),
          WorkoutScreen(),
          ScreenTrainingList(user: user),
          ScreenCalendar(user: user),
          ScreenMenu(user: user),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star_rounded), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Training'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
