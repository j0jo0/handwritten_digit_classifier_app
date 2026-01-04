import 'package:flutter/material.dart';

class DigitRecognitionScreen extends StatefulWidget {
  const DigitRecognitionScreen({super.key});

  @override
  State<DigitRecognitionScreen> createState() => _DigitRecognitionScreenState();
}

class _DigitRecognitionScreenState extends State<DigitRecognitionScreen> {
  List<Offset?> points = [];
  String recognizedDigit = '-';
  bool isAnalyzing = false;

  void clearCanvas() {
    setState(() {
      points.clear();
      recognizedDigit = '-';
    });
  }

  Future<void> analyzeDrawing() async {
    if (points.isEmpty) return;

    setState(() {
      isAnalyzing = true;
    });

    // Simuliere KI-Analyse (hier würde dein TFLite Model integriert werden)
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      recognizedDigit = '7'; // Beispiel-Ergebnis
      isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Title
              Center(
                child: Text(
                  'Digit Recognition',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.normal),
                ),
              ),

              SizedBox(height: 24),

              // Recognized-Digit-Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Recognized Digit',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    isAnalyzing
                        ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF2196F3),
                      ),
                    )
                        : Text(
                      recognizedDigit,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2196F3),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} /*
'Digit Recognition'           // Titel
'Recognized Digit'            // Ergebnis
'Clear'                       // Button
'Analyze'                     // Button*/

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

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
