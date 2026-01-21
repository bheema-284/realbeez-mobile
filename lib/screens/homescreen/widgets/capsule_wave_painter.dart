import 'package:flutter/material.dart';

class CapsuleWaveLinePainter extends CustomPainter {
  final double centerX;
  final double capsuleWidth;
  final double capsuleHeight;
  final double borderRadius;
  final Color? lineColor;

  CapsuleWaveLinePainter({
    required this.centerX,
    required this.capsuleWidth,
    required this.capsuleHeight,
    this.borderRadius = 8, // Reduced from 12
    this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a shader for fading effect at the ends
    final gradient = LinearGradient(
      colors: [
        // ignore: deprecated_member_use
        Colors.black.withOpacity(0.0),
        // ignore: deprecated_member_use
        Colors.black.withOpacity(0.60),
        // ignore: deprecated_member_use
        Colors.black.withOpacity(0.60),
        // ignore: deprecated_member_use
        Colors.black.withOpacity(0.0),
      ],
      stops: const [0.0, 0.1, 0.9, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final double left = centerX - capsuleWidth / 2;
    final double right = centerX + capsuleWidth / 2;
    final double top = 0;
    final double bottom = capsuleHeight;

    // Control point offsets for smooth curves
    final double curveOffset = 6.0;

    final path = Path();

    // Start from left edge at bottom
    path.moveTo(0, bottom);

    // Draw bottom line from left edge to capsule with smooth curve
    path.lineTo(left - curveOffset, bottom);

    // Smooth curve from horizontal to vertical at bottom-left
    path.quadraticBezierTo(left, bottom, left, bottom - curveOffset);

    // Draw left vertical line
    path.lineTo(left, top + borderRadius);

    // Draw top-left corner with reduced curve
    path.quadraticBezierTo(left, top, left + borderRadius, top);

    // Draw top line
    path.lineTo(right - borderRadius, top);

    // Draw top-right corner with reduced curve
    path.quadraticBezierTo(right, top, right, top + borderRadius);

    // Draw right vertical line
    path.lineTo(right, bottom - curveOffset);

    // Smooth curve from vertical to horizontal at bottom-right
    path.quadraticBezierTo(right, bottom, right + curveOffset, bottom);

    // Draw bottom line from capsule to right edge
    path.lineTo(size.width, bottom);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CapsuleWaveLinePainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.capsuleWidth != capsuleWidth ||
        oldDelegate.capsuleHeight != capsuleHeight ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.lineColor != lineColor;
  }
}
