import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

// Data class to hold the result
class RecognitionResult {
  final String recognizedDigit;
  final String topPredictions;

  RecognitionResult({required this.recognizedDigit, required this.topPredictions});
}

class DigitRecognizer {
  Interpreter? _interpreter;

  // Getter to access the interpreter securely
  Interpreter? get interpreter => _interpreter;

  // Method to load the Classifier
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mnist.tflite');
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  void close() {
    _interpreter?.close();
  }

  Future<RecognitionResult> recognize(List<Offset?> points) async {
    // If interpreter is null or the drawing has less than two pixels, return '-'
    if (interpreter == null || points.where((p) => p != null).length < 2) {
      return RecognitionResult(recognizedDigit: '-', topPredictions: '');
    }

    // Preprocess the drawing
    final input = await _preprocessDrawing(points);
    final inputArray = [input];

    // Prepare output
    final outputArray = List.filled(1, List<double>.filled(10, 0.0));

    // Run the model
    interpreter!.run(inputArray, outputArray);
    final probabilities = outputArray[0];

    // 4. Find top 3 predictions
    List<MapEntry<int, double>> indexedProbabilities = probabilities.asMap().entries.toList();
    indexedProbabilities.sort((a, b) => b.value.compareTo(a.value));

    String topPredictions = '';
    for (int i = 0; i < 3; i++) {
      String digit = indexedProbabilities[i].key.toString();
      String probability = (indexedProbabilities[i].value * 100).toStringAsFixed(1);
      topPredictions += '$digit: $probability%\n';
    }

    return RecognitionResult(
      recognizedDigit: indexedProbabilities[0].key.toString(),
      topPredictions: topPredictions.trim(),
    );
  }

  Future<List<double>> _preprocessDrawing(List<Offset?> points) async {
    // 1. Find the Bounding Box of the drawing
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

    // 2. Calculate the size of the drawing
    double width = maxX - minX;
    double height = maxY - minY;

    // 3. Make it square and add padding
    double size = (width > height ? width : height) + 40;

    // 4. Center the drawing in the square
    double offsetX = (size - width) / 2;
    double offsetY = (size - height) / 2;

    // 5. Render canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size, size),
      Paint()..color = Colors.white,
    );

    // Paint the drawing on it - centered
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 8.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Move and center the points
        final p1 = Offset(points[i]!.dx - minX + offsetX, points[i]!.dy - minY + offsetY);
        final p2 = Offset(points[i + 1]!.dx - minX + offsetX, points[i + 1]!.dy - minY + offsetY);
        canvas.drawLine(p1, p2, paint);
      }
    }

    // 6. Export the picture
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // 7. Scale it down to 28x28
    final originalImage = img.decodeImage(pngBytes)!;
    final resized = img.copyResize(
      originalImage,
      width: 28,
      height: 28,
      interpolation: img.Interpolation.cubic,
    );

    // 8. Convert to grayscale
    List<double> input = [];
    for (int y = 0; y < 28; y++) {
      for (int x = 0; x < 28; x++) {
        final pixel = resized.getPixel(x, y);
        final brightness = img.getLuminance(pixel);
        input.add(1.0 - (brightness / 255.0));
      }
    }

    // 7. Print CSV to console for Python plotting
    debugPrint('--- Start of 28x28 Grayscale Image (CSV-like) ---');
    for (int y = 0; y < 28; y++) {
      final row = input.sublist(y * 28, (y * 28) + 28);
      print(row.map((e) => e.toStringAsFixed(1)).join(','));
    }
    debugPrint('--- End of 28x28 Grayscale Image (CSV-like) ---');

    return input;
  }
}