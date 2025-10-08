import 'package:flutter/material.dart';

class PumpkinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    final orange = Paint()..color = const Color(0xFFFF7A1A);
    final dark = Paint()..color = const Color(0xFF8C3D00);
    final stem = Paint()..color = const Color(0xFF2E7D32);

    // pumpkin body
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.55), width: w * 0.8, height: h * 0.6),
      Radius.circular(w * 0.25),
    );
    canvas.drawRRect(body, orange);

    // ridges
    final ridge = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = w * 0.04
      ..style = PaintingStyle.stroke;
    for (var i = -2; i <= 2; i++) {
      final x = w * 0.5 + i * w * 0.12;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, h * 0.55), width: w * 0.5, height: h * 0.58),
        3.14, 3.14, false, ridge,
      );
    }

    // stem
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.22), width: w * 0.14, height: h * 0.2),
        Radius.circular(6),
      ),
      stem,
    );

    // face (friendly)
    final eye = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(w * 0.38, h * 0.55), w * 0.06, eye);
    canvas.drawCircle(Offset(w * 0.62, h * 0.55), w * 0.06, eye);

    final mouth = Paint()..color = const Color(0xFF1A1A1A);
    final mouthRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.7), width: w * 0.38, height: h * 0.1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(mouthRect, Radius.circular(12)), mouth,
    );

    // shadow
    final sh = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.95), width: w * 0.65, height: h * 0.08),
      sh,
    );
  }

  @override
  bool shouldRepaint(covariant PumpkinPainter oldDelegate) => false;
}