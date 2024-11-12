import 'package:flutter/material.dart';

/// `ThemeNotifier`는 앱의 테마(다크 모드와 라이트 모드)를 전환하기 위해 사용하는 클래스입니다.
/// `ChangeNotifier`를 상속받아 상태 변경 시 UI를 자동으로 업데이트할 수 있도록 합니다.
class ThemeNotifier extends ChangeNotifier {
  // 현재 다크 모드가 활성화되어 있는지를 나타내는 변수입니다.
  // 기본값은 `false`로, 라이트 모드가 기본 모드입니다.
  bool _isDarkMode = false;

  // 현재 다크 모드 활성화 여부를 반환합니다.
  bool get isDarkMode => _isDarkMode;

  // 현재 테마를 반환합니다.
  // `_isDarkMode`가 `true`일 경우 다크 테마를, `false`일 경우 라이트 테마를 반환합니다.
  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  /// 테마 전환 메서드입니다.
  /// 이 메서드는 현재 모드의 반대 모드로 전환하고,
  /// `notifyListeners()`를 호출하여 상태 변경을 알립니다.
  void toggleTheme() {
    _isDarkMode = !_isDarkMode; // 현재 모드의 반대로 변경
    notifyListeners(); // UI 업데이트 알림
  }
}

/// 라이트 테마 설정 (Material 3 적용)
/// `ThemeData`는 앱의 전반적인 스타일과 색상을 정의합니다.
final ThemeData _lightTheme = ThemeData(
  useMaterial3: true, // Material 3 디자인 시스템 적용
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), // 색상 팔레트를 teal 색상으로 설정
  textTheme: const TextTheme(
    // 큰 제목 스타일 정의
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto', // Roboto 폰트 사용
    ),
    // 본문 텍스트 스타일 정의
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: 'Roboto',
    ),
  ),
  cardTheme: CardTheme(
    // 카드 스타일 정의 (모서리 둥글기 설정)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: const EdgeInsets.all(10), // 카드의 기본 여백 설정
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    // FloatingActionButton 스타일 정의 (모서리 둥글기 설정)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
  dialogTheme: DialogTheme(
    // 다이얼로그 스타일 정의 (모서리 둥글기 설정)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
);

/// 다크 테마 설정 (Material 3 적용)
/// `ThemeData`는 앱의 다크 모드 스타일과 색상을 정의합니다.
final ThemeData _darkTheme = ThemeData(
  useMaterial3: true, // Material 3 디자인 시스템 적용
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal, // 색상 팔레트를 deepPurple 색상으로 설정
    brightness: Brightness.dark, // 다크 모드 적용
  ),
  textTheme: const TextTheme(
    // 큰 제목 스타일 정의
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    ),
    // 본문 텍스트 스타일 정의
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: 'Roboto',
    ),
  ),
  cardTheme: CardTheme(
    // 카드 스타일 정의 (모서리 둥글기 설정)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: const EdgeInsets.all(10), // 카드의 기본 여백 설정
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    // FloatingActionButton 스타일 정의 (모서리 둥글기 설정)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
  dialogTheme: DialogTheme(
    // 다이얼로그 스타일 정의 (모서리 둥글기 설정)
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
  ),
);
