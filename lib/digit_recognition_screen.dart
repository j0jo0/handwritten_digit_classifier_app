import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handwritten_digit_classifier_app/widgets/action_buttons.dart';
import 'package:handwritten_digit_classifier_app/widgets/drawing_canvas.dart';
import 'package:handwritten_digit_classifier_app/widgets/recognized_digit_card.dart';
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
      topPredictions = '';
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
              RecognizedDigitCard(isAnalyzing: isAnalyzing, recognizedDigit: recognizedDigit, topPredictions: topPredictions),

              SizedBox(height: 40.h),

              // Tip
              Text(
                'Draw digits small to achieve better results',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withAlpha(100),
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 10.h),

              // Canvas where you can draw
              DrawingCanvas(
                points: points,
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
              ),

              SizedBox(height: 30.h),
              // Spacer to push buttons down
              const Spacer(),

              // Buttons
              ActionButtons(
                onClear: clearCanvas,
                onAnalyze: points.where((p) => p != null).isEmpty ? null : _analyze,
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
