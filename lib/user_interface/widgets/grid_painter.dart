import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final int numColumns;
  final int numRows;
  final double cellSize;

  GridPainter({
    required this.numColumns,
    required this.numRows,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 1.0;

   
    for (int i = 1; i < numColumns; i++) {
      final dx = i * cellSize;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }

   
    for (int i = 1; i < numRows; i++) {
      final dy = i * cellSize;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.numColumns != numColumns ||
        oldDelegate.numRows != numRows ||
        oldDelegate.cellSize != cellSize;
  }
}