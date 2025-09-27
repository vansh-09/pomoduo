// lib/models/session.dart
class Session {
  final int? id;
  final DateTime startTime;
  final DateTime endTime;
  final bool completed;

  Session({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.completed,
  });

  Duration get duration => endTime.difference(startTime);

  double get durationInMinutes => duration.inSeconds / 60.0;

  String get formattedDate =>
      '${startTime.day}/${startTime.month}/${startTime.year}';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'completed': completed ? 1 : 0,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] as int?,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      completed: (map['completed'] as int) == 1,
    );
  }
}
