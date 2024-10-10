// theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true, // Material 3 적용
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // 색상 테마
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    ), // 큰 제목 글꼴 스타일
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: 'Roboto',
    ), // 본문 글꼴 스타일
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // 카드의 모서리를 둥글게
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24), // 플로팅 액션 버튼의 모서리 둥글게
    ),
  ),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24), // 다이얼로그의 모서리 둥글게
    ),
  ),
  // 추가적인 테마 속성들을 여기에 추가할 수 있습니다.
);
