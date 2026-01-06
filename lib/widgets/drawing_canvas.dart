import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget that displays the drawing canvas
class DrawingCanvas extends StatelessWidget {
  final List<Offset?> points;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;

  const DrawingCanvas({
    super.key,
    required this.points,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Style the canvas
      height: 280.w,
      width: 280.w,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withAlpha(75),
              blurRadius: 30.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        // Clip the canvas
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: GestureDetector(
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            // Content of the canvas
            child: CustomPaint(
              painter: DrawingPainter(points),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget that helps you draw on the canvas
class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // Define and style the Stroke
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0.w;

    // Draw the lines
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  // Update the canvas
  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return true;
  }
}
