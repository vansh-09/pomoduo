import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _focusMinutes = 25;
  int _breakMinutes = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _focusMinutes = prefs.getInt('focusMinutes') ?? 25;
      _breakMinutes = prefs.getInt('breakMinutes') ?? 5;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focusMinutes', _focusMinutes);
    await prefs.setInt('breakMinutes', _breakMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Focus Duration (minutes)"),
              trailing: DropdownButton<int>(
                value: _focusMinutes,
                items: [15, 20, 25, 30, 45, 60]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text("$e"),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _focusMinutes = val);
                  _saveSettings();
                },
              ),
            ),
            ListTile(
              title: const Text("Break Duration (minutes)"),
              trailing: DropdownButton<int>(
                value: _breakMinutes,
                items: [3, 5, 10, 15, 20]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text("$e"),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _breakMinutes = val);
                  _saveSettings();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}