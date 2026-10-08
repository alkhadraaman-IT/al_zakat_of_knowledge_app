import 'package:flutter/material.dart';

/// Shared neon blueprint map-grid painter.
/// Replaces the duplicated private `_MapGridPainter` classes that
/// previously existed across Home, Search, Favorites, Session Details
/// and the shared session card.
class AppMapGridPainter extends CustomPainter {
  final Color lineColor;
  final double gridSize;
  final double strokeWidth;

  const AppMapGridPainter({
    required this.lineColor,
    this.gridSize = 32.0,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant AppMapGridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.gridSize != gridSize ||
      oldDelegate.strokeWidth != strokeWidth;
}
