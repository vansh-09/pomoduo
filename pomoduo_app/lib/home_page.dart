import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/auth_page.dart';
import 'pages/settings_page.dart';
import 'pages/sessions_page.dart';
import 'pages/stats_page.dart';
import 'db/session_db.dart';
import 'models/session.dart';
import 'package:confetti/confetti.dart';
import 'widgets/circular_button.dart';
import 'widgets/circular_timer_painter.dart';

// ---------------- HOME PAGE ----------------
class HomePage extends StatefulWidget {
  final VoidCallback? onLogout;

  const HomePage({super.key, this.onLogout});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1;

  final List<Widget> _pages = const [SessionsPage(), TimerPage(), StatsPage()];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (widget.onLogout != null) {
      widget.onLogout!();
    } else if (mounted) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PomoDuo'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout)
        ],
      ),
      body: PageView(
          controller: _pageController,
          children: _pages,
          onPageChanged: (i) => setState(() => _selectedIndex = i)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121214),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF9B4CFF),
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Sessions'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}

// ---------------- TIMER PAGE ----------------
class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

// <rest of your TimerPage code remains unchanged>
