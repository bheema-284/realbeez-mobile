import 'package:flutter/material.dart';

class CapsuleWaveLinePainter extends CustomPainter {
  final double centerX;
  final double capsuleWidth;
  final double capsuleHeight;
  final double borderRadius;

  CapsuleWaveLinePainter({
    required this.centerX,
    required this.capsuleWidth,
    required this.capsuleHeight,
    this.borderRadius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final leftX = centerX - capsuleWidth / 2;
    final rightX = centerX + capsuleWidth / 2;

    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(leftX, 0);

    path.arcToPoint(
      Offset(leftX + borderRadius, -borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: false,
    );
    path.lineTo(leftX + borderRadius, -capsuleHeight + borderRadius);
    path.arcToPoint(
      Offset(leftX + borderRadius * 2, -capsuleHeight),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );
    path.lineTo(rightX - borderRadius * 2, -capsuleHeight);
    path.arcToPoint(
      Offset(rightX - borderRadius, -capsuleHeight + borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: true,
    );
    path.lineTo(rightX - borderRadius, -borderRadius);
    path.arcToPoint(
      Offset(rightX, 0),
      radius: Radius.circular(borderRadius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);

    canvas.translate(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CapsuleWaveLinePainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.capsuleWidth != capsuleWidth ||
        oldDelegate.capsuleHeight != capsuleHeight ||
        oldDelegate.borderRadius != borderRadius;
  }
}

