import 'package:flutter/material.dart';

class ScreenRoutine extends StatelessWidget {
  final String routineName;

  ScreenRoutine({required this.routineName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 1, // 리스트 아이템은 하나
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(routineName),
          );
        },
      ),
    );
  }
}
