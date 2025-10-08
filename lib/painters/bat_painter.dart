import 'package:flutter/material.dart';
import 'dart:math' as math;

class BatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final bodyPaint = Paint()..color = Colors.black87;
    final wingPaint = Paint()..color = const Color(0xFF121212);

    // body
    final body = Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.5), width: w * 0.25, height: h * 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, Radius.circular(w * 0.12)),
      bodyPaint,
    );

    // head
    canvas.drawCircle(Offset(w * 0.5, h * 0.32), w * 0.12, bodyPaint);

    // wings
    final leftWing = Path()
      ..moveTo(w * 0.38, h * 0.45)
      ..quadraticBezierTo(w * 0.1, h * 0.2, w * 0.05, h * 0.55)
      ..quadraticBezierTo(w * 0.18, h * 0.5, w * 0.28, h * 0.62)
      ..quadraticBezierTo(w * 0.32, h * 0.55, w * 0.38, h * 0.45)
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    final rightWing = Path()
      ..moveTo(w * 0.62, h * 0.45)
      ..quadraticBezierTo(w * 0.9, h * 0.2, w * 0.95, h * 0.55)
      ..quadraticBezierTo(w * 0.82, h * 0.5, w * 0.72, h * 0.62)
      ..quadraticBezierTo(w * 0.68, h * 0.55, w * 0.62, h * 0.45)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    // eyes
    final eye = Paint()..color = Colors.amberAccent;
    canvas.drawCircle(Offset(w * 0.46, h * 0.30), w * 0.02, eye);
    canvas.drawCircle(Offset(w * 0.54, h * 0.30), w * 0.02, eye);

    // tiny fangs
    final fang = Paint()..color = Colors.white;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.49, h * 0.34)
        ..lineTo(w * 0.485, h * 0.36)
        ..lineTo(w * 0.495, h * 0.34),
      fang,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.51, h * 0.34)
        ..lineTo(w * 0.515, h * 0.36)
        ..lineTo(w * 0.505, h * 0.34),
      fang,
    );

    // subtle bottom shadow
    final shadow = Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.92),
        width: w * 0.38,
        height: h * 0.08,
      ),
      shadow,
    );
  }

  @override
  bool shouldRepaint(covariant BatPainter oldDelegate) => false;
}