import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class ScreenCalendar extends StatefulWidget {
  @override
  _ScreenCalendarState createState() => _ScreenCalendarState();
}

class _ScreenCalendarState extends State<ScreenCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _firstDay = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  DateTime _lastDay = DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // Initialize date formatting for the locale
  }

  void _showBottomSheet(BuildContext context, DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.black87,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.note_add, color: Colors.white),
                title: Text('메모 작성', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // 메모 작성 페이지로 이동하는 코드 추가
                },
              ),
              ListTile(
                leading: Icon(Icons.fitness_center, color: Colors.white),
                title: Text('운동 기록', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  // 운동 기록 페이지로 이동하는 코드 추가
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('달력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTableCalendar(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  TableCalendar _buildTableCalendar() {
    return TableCalendar(
      locale: 'ko_KR',
      firstDay: _firstDay,
      lastDay: _lastDay,
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _showBottomSheet(context, selectedDay);
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: _buildCalendarStyle(),
      daysOfWeekStyle: _buildDaysOfWeekStyle(),
      headerStyle: _buildHeaderStyle(),
      calendarBuilders: _buildCalendarBuilders(),
    );
  }

  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: Colors.transparent, // 투명색으로 설정하여 선택된 날짜의 원을 없앱니다.
      ),
      todayDecoration: BoxDecoration(
        color: Colors.transparent, // 원이 없는 투명한 배경 설정
      ),
      todayTextStyle: TextStyle(
        color: Colors.orange, // 오늘 날짜의 텍스트 색상 설정
        fontWeight: FontWeight.bold,
      ),
      weekendTextStyle: TextStyle(
        color: Colors.black, // 기본 주말 텍스트 색상
      ),
      defaultTextStyle: TextStyle(
        color: Colors.white, // 기본 평일 텍스트 색상
      ),
    );
  }

  DaysOfWeekStyle _buildDaysOfWeekStyle() {
    return DaysOfWeekStyle(
      weekdayStyle: TextStyle(
        color: Colors.white, // 평일 텍스트 색상을 흰색으로 설정
      ),
      weekendStyle: TextStyle(
        color: Colors.black, // 기본 주말 텍스트 색상
      ),
    );
  }

  HeaderStyle _buildHeaderStyle() {
    return HeaderStyle(
      formatButtonVisible: false, // 월 형식 전환 버튼을 숨김
    );
  }

  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      dowBuilder: (context, day) {
        if (day.weekday == DateTime.sunday) {
          return Center(
            child: Text(
              '일',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          );
        } else if (day.weekday == DateTime.saturday) {
          return Center(
            child: Text(
              '토',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          );
        } else {
          return Center(
            child: Text(
              _getWeekdayLabel(day.weekday),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        }
      },
      defaultBuilder: (context, day, focusedDay) {
        if (day.weekday == DateTime.sunday) {
          return Center(
            child: Text(
              '${day.day}',
              style: TextStyle(color: Color.fromARGB(255, 149, 46, 38), fontWeight: FontWeight.bold),
            ),
          );
        } else if (day.weekday == DateTime.saturday) {
          return Center(
            child: Text(
              '${day.day}',
              style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
            ),
          );
        }
        return Center(
          child: Text(
            '${day.day}',
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
      selectedBuilder: (context, day, focusedDay) {
        final isOutsideMonth = day.month != focusedDay.month;
        if (isSameDay(day, DateTime.now())) {
          return Center(
            child: Text(
              '${day.day}',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          );
        }
        if (day.weekday == DateTime.sunday) {
          return Center(
            child: Text(
              '${day.day}',
              style: TextStyle(color: isOutsideMonth ? Color.fromARGB(255, 149, 46, 38).withOpacity(0.5) : Color.fromARGB(255, 149, 46, 38), fontWeight: FontWeight.bold),
            ),
          );
        } else if (day.weekday == DateTime.saturday) {
          return Center(
            child: Text(
              '${day.day}',
              style: TextStyle(color: isOutsideMonth ? Colors.indigo.withOpacity(0.5) : Colors.indigo, fontWeight: FontWeight.bold),
            ),
          );
        }
        return Center(
          child: Text(
            '${day.day}',
            style: TextStyle(color: isOutsideMonth ? Colors.grey.withOpacity(0.5) : Colors.grey),
          ),
        );
      },
      outsideBuilder: (context, day, focusedDay) {
        if (day.weekday == DateTime.sunday) {
          return Center(
            child: Text(
              '${day.day}',
              style: TextStyle(color: Color.fromARGB(255, 149, 46, 38).withOpacity(0.5), fontWeight: FontWeight.bold),
            ),
          );
        } else if (day.weekday == DateTime.saturday) {
          return Center(
            child: Text(
              '${day.day}',
              style: TextStyle(color: Colors.indigo.withOpacity(0.5), fontWeight: FontWeight.bold),
            ),
          );
        }
        return Center(
          child: Text(
            '${day.day}',
            style: TextStyle(color: Colors.grey.withOpacity(0.5)),
          ),
        );
      },
    );
  }

  String _getWeekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '월';
      case DateTime.tuesday:
        return '화';
      case DateTime.wednesday:
        return '수';
      case DateTime.thursday:
        return '목';
      case DateTime.friday:
        return '금';
      default:
        return '';
    }
  }
}
