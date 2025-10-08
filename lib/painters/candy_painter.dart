import 'package:flutter/material.dart';

class CandyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Wrapper triangles
    final wrap = Paint()..color = const Color(0xFFFFC107);
    final left = Path()
      ..moveTo(w * 0.18, h * 0.5)
      ..lineTo(w * 0.04, h * 0.38)
      ..lineTo(w * 0.04, h * 0.62)
      ..close();
    final right = Path()
      ..moveTo(w * 0.82, h * 0.5)
      ..lineTo(w * 0.96, h * 0.38)
      ..lineTo(w * 0.96, h * 0.62)
      ..close();
    canvas.drawPath(left, wrap);
    canvas.drawPath(right, wrap);

    // Candy center
    final base = Paint()..color = const Color(0xFFFF6A00);
    final center = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: w * 0.5, height: h * 0.38),
      Radius.circular(30),
    );
    canvas.drawRRect(center, base);

    // swirl
    final swirl = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final rect = Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: w * 0.42, height: h * 0.32);
    canvas.drawArc(rect, 0, 3.14 * 1.7, false, swirl);
    canvas.drawArc(rect.inflate(-10), 3.14 * 0.5, 3.14 * 1.6, false, swirl);
  }

  @override
  bool shouldRepaint(covariant CandyPainter oldDelegate) => false;
}
