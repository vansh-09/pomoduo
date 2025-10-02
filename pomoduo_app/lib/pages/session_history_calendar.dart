import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../db/session_db.dart';
import '../models/session.dart';

class SessionHistoryCalendar extends StatefulWidget {
  const SessionHistoryCalendar({super.key});

  @override
  State<SessionHistoryCalendar> createState() => _SessionHistoryCalendarState();
}

class _SessionHistoryCalendarState extends State<SessionHistoryCalendar> {
  Map<DateTime, int> sessionsPerDay = {};
  bool loading = true;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final List<Session> sessions = await SessionDB.instance.fetchSessions();

    // Group session counts per day
    sessionsPerDay.clear();
    for (var session in sessions) {
      final day = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      sessionsPerDay[day] = (sessionsPerDay[day] ?? 0) + 1;
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (sessionsPerDay.isEmpty) return const Center(child: Text("No sessions yet."));

    final maxCount = sessionsPerDay.values.isNotEmpty ? sessionsPerDay.values.reduce((a, b) => a > b ? a : b) : 1;
    final themeColour = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: TableCalendar(
        firstDay: DateTime.utc(2021, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: DateTime.now(),
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            int count = sessionsPerDay[DateTime(day.year, day.month, day.day)] ?? 0;
            Color cellColor = count == 0
                ? Colors.grey[800]!
                : Color.lerp(Colors.grey[200], themeColour, (count / (maxCount == 0 ? 1 : maxCount)).clamp(0.0, 1.0))!;

            return Container(
              decoration: BoxDecoration(
                color: cellColor,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: count == 0
                      ? Colors.white70
                      : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
