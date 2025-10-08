import 'package:flutter/material.dart';

class GhostPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()..color = Colors.white.withOpacity(0.94);
    final shadow = Paint()
      ..color = const Color(0x66FFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final w = size.width, h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..quadraticBezierTo(w * 0.9, h * 0.1, w * 0.85, h * 0.55)
      ..quadraticBezierTo(w * 0.86, h * 0.72, w * 0.8, h * 0.75)
      ..lineTo(w * 0.7, h * 0.9)
      ..lineTo(w * 0.6, h * 0.78)
      ..lineTo(w * 0.5, h * 0.92)
      ..lineTo(w * 0.4, h * 0.78)
      ..lineTo(w * 0.3, h * 0.9)
      ..lineTo(w * 0.2, h * 0.75)
      ..quadraticBezierTo(w * 0.14, h * 0.72, w * 0.15, h * 0.55)
      ..quadraticBezierTo(w * 0.1, h * 0.1, w * 0.5, h * 0.1)
      ..close();

    canvas.drawPath(path, shadow);
    canvas.drawPath(path, body);

    // eyes
    final eye = Paint()..color = Colors.black.withOpacity(0.9);
    canvas.drawCircle(Offset(w * 0.4, h * 0.38), w * 0.055, eye);
    canvas.drawCircle(Offset(w * 0.6, h * 0.38), w * 0.055, eye);

    // mouth
    final mouth = Paint()..color = Colors.black.withOpacity(0.84);
    final mouthRect = Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.52), width: w * 0.18, height: h * 0.06);
    canvas.drawRRect(
      RRect.fromRectAndRadius(mouthRect, Radius.circular(w * 0.04)),
      mouth,
    );
  }

  @override
  bool shouldRepaint(covariant GhostPainter oldDelegate) => false;
}

