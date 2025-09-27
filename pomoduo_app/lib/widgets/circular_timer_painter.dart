import 'package:flutter/material.dart';

class CircularTimerPainter extends CustomPainter {
  final double progress;
  final bool isRunning;

  CircularTimerPainter({required this.progress, required this.isRunning});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint basePaint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final Paint progressPaint = Paint()
      ..color = isRunning ? Colors.purpleAccent : Colors.grey
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Draw base circle
    canvas.drawCircle(center, radius, basePaint);

    // Draw progress arc
    final double sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
