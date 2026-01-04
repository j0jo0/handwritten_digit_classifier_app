import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

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

  Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mnist.tflite');
      debugPrint('Model loaded successfully');

    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  void clearCanvas() {
    setState(() {
      points.clear();
      recognizedDigit = '-';
    });
  }

  Future<void> analyzeDrawing() async {
    if (points.isEmpty || _interpreter == null) return;

    setState(() {
      isAnalyzing = true;
    });

    try {
      // Convert Canvas to Image
      List<double> input = await preprocessDrawing();

      // prepare the Input Array (1x784 for the 784 pixels)
      var inputArray = [input];

      // prepare the Output Array (1x10 for the 10 digits)
      var outputArray = List.filled(1, List<double>.filled(10,0.0));

      // run the model
      _interpreter!.run(inputArray, outputArray);

      // Erstelle eine Liste mit (Ziffer, Wahrscheinlichkeit) Paaren
      List<MapEntry<int, double>> predictions = [];
      for (int i = 0; i < 10; i++) {
        predictions.add(MapEntry(i, outputArray[0][i]));
      }

      // Sortiere nach Wahrscheinlichkeit (absteigend)
      predictions.sort((a, b) => b.value.compareTo(a.value));

      // Top 3 extrahieren
      int firstDigit = predictions[0].key;
      double firstProb = predictions[0].value;

      String top3Text = '';
      for (int i = 0; i < 3 && i < predictions.length; i++) {
        double percentage = predictions[i].value * 100;
        top3Text += '${predictions[i].key}: ${percentage.toStringAsFixed(1)}%';
        if (i < 2) top3Text += '\n';
      }

      debugPrint('Top 3 predictions:');
      for (int i = 0; i < 3; i++) {
        debugPrint('  ${i + 1}. Digit ${predictions[i].key}: ${(predictions[i].value * 100).toStringAsFixed(2)}%');
      }

      setState(() {
        recognizedDigit = firstDigit.toString();
        topPredictions = top3Text;
        isAnalyzing = false;
      });
    } catch (e) {
      debugPrint('Error analyzing drawing: $e');
      setState(() {
        isAnalyzing = false;
      });
    }
  }

  Future<List<double>> preprocessDrawing() async {
    // 1. Finde die Bounding Box der Zeichnung
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (var point in points) {
      if (point != null) {
        if (point.dx < minX) minX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy > maxY) maxY = point.dy;
      }
    }

    // 2. Berechne die Größe der Zeichnung
    double width = maxX - minX;
    double height = maxY - minY;

    // 3. Mache es quadratisch (nimm die größere Dimension)
    double size = width > height ? width : height;
    size += 40; // Padding hinzufügen

    // 4. Zentriere die Zeichnung im Quadrat
    double offsetX = (size - width) / 2;
    double offsetY = (size - height) / 2;

    debugPrint('Drawing bounds: minX=$minX, minY=$minY, maxX=$maxX, maxY=$maxY');
    debugPrint('Square size: $size, offsetX=$offsetX, offsetY=$offsetY');

    // 5. Canvas rendern (quadratisch!)
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Weißer Hintergrund
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size, size),
      Paint()..color = Colors.white,
    );

    // Zeichnung drauf malen - zentriert
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15.0; // Etwas dünner für bessere Details

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Verschiebe und zentriere die Punkte
        final p1 = Offset(
            points[i]!.dx - minX + offsetX,
            points[i]!.dy - minY + offsetY
        );
        final p2 = Offset(
            points[i + 1]!.dx - minX + offsetX,
            points[i + 1]!.dy - minY + offsetY
        );
        canvas.drawLine(p1, p2, paint);
      }
    }

    // 6. Als Bild exportieren
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // 7. Auf 28x28 runterskalieren
    img.Image? originalImage = img.decodeImage(pngBytes);
    img.Image resized = img.copyResize(
      originalImage!,
      width: 28,
      height: 28,
      interpolation: img.Interpolation.cubic,
    );

    // 8. In Graustufenwerte umwandeln
    List<double> input = [];
    for (int y = 0; y < 28; y++) {
      for (int x = 0; x < 28; x++) {
        final pixel = resized.getPixel(x, y);
        final brightness = img.getLuminance(pixel);
        input.add(1.0 - (brightness / 255.0));
      }
    }

    debugPrint('Input stats: sum=${input.reduce((a, b) => a + b).toStringAsFixed(2)}, min=${input.reduce((a, b) => a < b ? a : b).toStringAsFixed(3)}, max=${input.reduce((a, b) => a > b ? a : b).toStringAsFixed(3)}');

    return input;
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
                          onTap: points.isEmpty ? null : analyzeDrawing,
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

