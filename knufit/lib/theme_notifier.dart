import 'package:flutter/material.dart';

/// ThemeNotifier는 앱의 다크 모드 및 라이트 모드를 전환할 수 있도록 하는 클래스입니다.
/// ChangeNotifier를 상속받아 상태 변경 시 UI를 업데이트합니다.
class ThemeNotifier extends ChangeNotifier {
  // 다크 모드 여부를 나타내는 변수 (기본값은 라이트 모드)
  bool _isDarkMode = false;

  // 현재 다크 모드 여부를 반환
  bool get isDarkMode => _isDarkMode;

  // 현재 테마를 반환 (다크 모드면 다크 테마, 아니면 라이트 테마)
  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  // 테마 전환 메서드 (다크 모드와 라이트 모드를 토글)
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // 상태 변경 알림
  }
}

/// 공통 라이트 테마 (Material 3 적용)
final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: 'Roboto',
    ),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: const EdgeInsets.all(10),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
);

/// 공통 다크 테마 (Material 3 적용)
final ThemeData _darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: 'Roboto',
    ),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: const EdgeInsets.all(10),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
);
