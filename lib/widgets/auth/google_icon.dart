import 'package:flutter/material.dart';

/// Vector-drawn crisp Google Icon widget with high aesthetic standard.
class GoogleIcon extends StatelessWidget {
  const GoogleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(18, 18), painter: _GoogleIconPainter());
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = w / 2;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Top Arc (Red)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), -2.7, 1.9, true, paint);

    // Left Arc (Yellow)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), -4.4, 1.7, true, paint);

    // Bottom Arc (Green)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), -0.8, 1.9, true, paint);

    // Right Arc (Blue)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromLTWH(0, 0, w, h), -0.8, -1.9, true, paint);

    // Inner ring (Clean White background cutout)
    paint.color = Colors.white; // Matches Google button background
    canvas.drawCircle(Offset(r, r), r * 0.55, paint);

    // Right horizontal bar (Blue)
    paint.color = const Color(0xFF4285F4);
    final double barW = r * 0.85;
    final double barH = r * 0.35;
    canvas.drawRect(Rect.fromLTWH(r, r - barH / 2, barW, barH), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
