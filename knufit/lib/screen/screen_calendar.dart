import 'package:flutter/material.dart';
import 'package:knufit/screen/calendar_screen/date_memo_func.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'calendar_screen/screen_date_memo_create.dart';
import 'calendar_screen/screen_date_memo_edit.dart';

class ScreenCalendar extends StatefulWidget {
  @override
  _ScreenCalendarState createState() => _ScreenCalendarState();

  final Map<String, dynamic> user;
  const ScreenCalendar({required this.user, Key? key}) : super(key:key);
}

class _ScreenCalendarState extends State<ScreenCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _firstDay = DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
  DateTime _lastDay = DateTime(DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);
  DateTime? _selectedDay;

  List<Map<String, dynamic>> _datememos = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // Initialize date formatting for the locale
    readDateMemosAllClient(widget.user["id"]);
  }

  Future<void> readDateMemosAllClient(int userId) async {
    final tempDateMemos = await readDateMemosAllServer(userId);
    setState(() {
      _datememos = tempDateMemos;
    });
    print("datememos update!");
  }

  void _showBottomSheet(BuildContext context, DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일',
                style: TextStyle(fontSize: 20, color: Colors.orange),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.note_add, color: Colors.orange),
                title: Text(
                  '메모 작성', style: TextStyle(color: Colors.grey)
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DateMemoCreatePage(user: widget.user, date: selectedDay),
                    ),
                  ).then((_) {
                    readDateMemosAllClient(widget.user["id"]); // 메모 작성 후 모든 메모 목록을 갱신합니다.
                  });
                },
              )
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
        title: Text('캘린더'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTableCalendar(),
            SizedBox(height: 20),
            _buildMemoList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _datememos.length,
        itemBuilder: (context, index) {
          final datememo = _datememos[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DateMemoEditPage(datememo: datememo),
                ),
              ).then((_) {
                readDateMemosAllClient(widget.user["id"]); // 메모 작성 후 모든 메모 목록을 갱신합니다.
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[500]!, Colors.orange[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        datememo['datetime'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          datememo['title'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
