import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'digit_recognition_screen.dart';

void main() {
  runApp(const MNISTApp());
}

class MNISTApp extends StatelessWidget {
  const MNISTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 851),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context , child) {
        return MaterialApp(
          title: 'MNIST Ziffern-Erkennung',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0A1929),
            primaryColor: const Color(0xFF2196F3),
          ),
          home: const DigitRecognitionScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
