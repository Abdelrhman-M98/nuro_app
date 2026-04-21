import 'dart:math' as math;
import 'package:flutter/material.dart';

class SignalWavePainter extends CustomPainter {
  SignalWavePainter({
    required this.phase,
    required this.waveColor,
    this.alpha = 0.6,
  });

  final double phase;
  final Color waveColor;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    const lineCount = 3;
    const amplitude = 12.0;
    const period = 0.015;
    const strokeWidth = 2.0;

    final paint = Paint()
      ..color = waveColor.withValues(alpha: alpha)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int L = 0; L < lineCount; L++) {
      final path = Path();
      final yBase = size.height * (0.15 + 0.2 * L);
      final offset = L * 0.4 + phase;

      for (double x = 0; x <= size.width + 20; x += 3) {
        final t = x * period + offset;
        final y = yBase +
            math.sin(t) * amplitude +
            math.sin(t * 2.3 + 1) * (amplitude * 0.5);
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SignalWavePainter old) =>
      old.phase != phase || old.waveColor != waveColor || old.alpha != alpha;
}
