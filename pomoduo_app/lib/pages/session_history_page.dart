import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/session_db.dart';
import '../models/session.dart';

class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  List<Session> sessions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    sessions = await SessionDB.instance.fetchSessions();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (sessions.isEmpty) return const Center(child: Text("No sessions yet."));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        Session session = sessions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: session.completed ? Colors.green : Colors.orange,
              child: Icon(
                session.completed ? Icons.check : Icons.pause,
                color: Colors.white,
              ),
            ),
            title: Text(
              "Session on ${DateFormat.yMMMd().format(session.startTime)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Duration: ${session.durationInMinutes.toStringAsFixed(1)} mins ${session.completed ? '(Completed)' : '(Paused)'}",
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
