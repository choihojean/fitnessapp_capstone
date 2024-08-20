import 'package:flutter/material.dart';

class RoutineProvider with ChangeNotifier {
  List<String> _tableNames = [];

  List<String> get tableNames => _tableNames;

  // 루틴 목록을 설정하는 메서드
  void setTableNames(List<String> names) {
    _tableNames = names;
    notifyListeners(); // 상태 변경 알림
  }

  // 새로운 루틴을 추가하는 메서드
  void addTableName(String name) {
    _tableNames.add(name);
    notifyListeners();
  }

  // 특정 루틴을 삭제하는 메서드
  void removeTableName(String name) {
    _tableNames.remove(name);
    notifyListeners();
  }
}
