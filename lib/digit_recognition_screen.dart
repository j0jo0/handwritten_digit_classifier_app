
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'services/digit_recognizer.dart';

class DigitRecognitionScreen extends StatefulWidget {
  const DigitRecognitionScreen({super.key});

  @override
  State<DigitRecognitionScreen> createState() => _DigitRecognitionScreenState();
}

class _DigitRecognitionScreenState extends State<DigitRecognitionScreen> {
  List<Offset?> points = [];
  String recognizedDigit = '-';
  String topPredictions = '';
  bool isAnalyzing = false;

  final DigitRecognizer _digitRecognizer = DigitRecognizer();

  @override
  void initState() {
    super.initState();
    _digitRecognizer.loadModel();
  }

  @override
  void dispose() {
    _digitRecognizer.close();
    super.dispose();
  }

  void clearCanvas() {
    setState(() {
      points.clear();
      recognizedDigit = '-';
      topPredictions = ''; // Also clear predictions
    });
  }

  Future<void> _analyze() async {
    if (points.where((p) => p != null).isEmpty) return;

    setState(() {
      isAnalyzing = true;
    });

    final result = await _digitRecognizer.recognize(points);

    setState(() {
      recognizedDigit = result.recognizedDigit;
      topPredictions = result.topPredictions;
      isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // Title
              Center(
                child: Text(
                  'Digit Recognition',
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.normal),
                ),
              ),

              SizedBox(height: 24.h),

              // Recognized-Digit-Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 24.h,
                  horizontal: 20.w,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withAlpha(25),
                      Colors.white.withAlpha(12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withAlpha(50),
                    width: 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 20.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Recognized Digit',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withAlpha(150),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    isAnalyzing
                        ? SizedBox(
                      width: 30.w,
                      height: 30.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.w,
                        color: const Color(0xFF2196F3),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: .spaceAround,
                      children: [
                        Text(
                          recognizedDigit,
                          style: TextStyle(
                            fontSize: 56.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2196F3),
                            letterSpacing: 2,
                          ),
                        ),
                        if (topPredictions.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Column(
                            children: [
                              Text(
                                'Top 3 Predictions',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white.withAlpha(100),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                topPredictions,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withAlpha(180),
                                  height: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          )

                        ],
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),
              Text(
                'Draw digits small and centered',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withAlpha(100),
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 10.h),

              // Canvas where you can draw
              SizedBox(
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          points.add(details.localPosition);
                        });
                      },
                      onPanEnd: (details) {
                        setState(() {
                          points.add(null);
                        });
                      },
                      child: CustomPaint(
                        painter: DrawingPainter(points),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30.h),
              // Spacer to push buttons down
              const Spacer(),

              // Buttons
              Row(
                children: [
                  // Clear Button
                  Expanded(
                    child: Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withAlpha(75),
                          width: 2.w,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: clearCanvas,
                          borderRadius: BorderRadius.circular(16.r),
                          child: Center(
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withAlpha(225),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Analyze button
                  Expanded(
                    child: Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withAlpha(100),
                            blurRadius: 15.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: points.isEmpty ? null : _analyze,
                          borderRadius: BorderRadius.circular(16.r),
                          child: Center(
                            child: Text(
                              'Analyze',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0.w;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

