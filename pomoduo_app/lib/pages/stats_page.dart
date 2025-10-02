import 'package:flutter/material.dart';
import '../db/session_db.dart';
import '../models/session.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int totalSessions = 0;
  double averageDurationMinutes = 0.0;
  bool isLoading = true;

  List<DateTime> days = [];
  Map<DateTime, int> sessionsPerDay = {};
  Map<DateTime, double> sessionTimePerDay = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      List<Session> sessions = await SessionDB.instance.fetchSessions();
      if (sessions.isNotEmpty) {
        // Get days for last 7 days
        final now = DateTime.now();
        days = List.generate(
          7,
          (i) => DateTime(now.year, now.month, now.day - (6 - i)),
        );

        // Group sessions and time per day
        for (var d in days) {
          sessionsPerDay[d] = 0;
          sessionTimePerDay[d] = 0.0;
        }

        for (var session in sessions) {
          final day = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
          if (sessionsPerDay.containsKey(day)) {
            sessionsPerDay[day] = sessionsPerDay[day]! + 1;
            sessionTimePerDay[day] = sessionTimePerDay[day]! + session.duration.inMinutes;
          }
        }

        double totalDurationMinutes = sessions.fold(
            0.0, (sum, session) => sum + session.duration.inMinutes.toDouble());

        setState(() {
          totalSessions = sessions.length;
          averageDurationMinutes = totalDurationMinutes / totalSessions;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (totalSessions == 0)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.bar_chart,
                          size: 80,
                          color: Colors.white30,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No Sessions Yet',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Complete some pomodoro sessions to see your stats',
                          style: TextStyle(
                            color: Colors.white54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      _buildStatCard(
                        'Total Sessions',
                        totalSessions.toString(),
                        Icons.play_circle_fill,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        'Average Duration',
                        '${averageDurationMinutes.toStringAsFixed(1)} min',
                        Icons.timer,
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        'Total Focus Time',
                        '${(totalSessions * 25)} min',
                        Icons.access_time,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Sessions Per Day (Last 7 Days)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            barGroups: List.generate(days.length, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: (sessionsPerDay[days[i]] ?? 0).toDouble(),
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx < 0 || idx >= days.length) return Container();
                                    String dayLabel = DateFormat('EEE').format(days[idx]);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(dayLabel,
                                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Sessioned Time Per Day (Last 7 Days)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                color: Colors.orangeAccent,
                                spots: List.generate(days.length, (i) =>
                                    FlSpot(i.toDouble(), (sessionTimePerDay[days[i]] ?? 0.0))),
                                isCurved: true,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx < 0 || idx >= days.length) return Container();
                                    String dayLabel = DateFormat('EEE').format(days[idx]);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(dayLabel,
                                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9B4CFF).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF9B4CFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF9B4CFF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
