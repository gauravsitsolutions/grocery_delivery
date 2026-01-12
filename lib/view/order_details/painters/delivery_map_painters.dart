import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1.5;

    const step = 40.0;

    // Draw dots
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.routeColor.withValues(alpha: 0.8) // Brand Green light
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Create a curved path similar to the image
    // Starting near bottom left (User)
    final startX = size.width * 0.3;
    final startY = size.height * 0.55; // aligned with bottom marker

    // Ending near top right (Destination)
    final endX = size.width * 0.75;
    final endY = size.height * 0.2; // aligned with top marker

    path.moveTo(startX, startY);

    // Curve control points
    final cp1X = size.width * 0.3;
    final cp1Y = size.height * 0.35;

    final cp2X = size.width * 0.5;
    final cp2Y = size.height * 0.15;

    path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, endX, endY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
