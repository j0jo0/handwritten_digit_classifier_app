import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget that displays the recognized digit and top predictions
class RecognizedDigitCard extends StatelessWidget {
  final bool isAnalyzing;
  final String recognizedDigit;
  final String topPredictions;
  const RecognizedDigitCard({
    super.key,
    required this.isAnalyzing,
    required this.recognizedDigit,
    required this.topPredictions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Style the card
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withAlpha(25), Colors.white.withAlpha(12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withAlpha(50), width: 1.5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      // Display the content of the card
      child: Column(
        children: [
          // Title
          Text(
            'Recognized Digit',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withAlpha(150),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          // Loading or recognized digit
          isAnalyzing
              ? SizedBox(
                  width: 30.w,
                  height: 30.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                    color: const Color(0xFF2196F3),
                  ),
                )
              // Recognized digit and top predictions
              : Row(
                  mainAxisAlignment: .spaceAround,
                  children: [
                    // Recognized digit
                    Text(
                      recognizedDigit,
                      style: TextStyle(
                        fontSize: 56.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2196F3),
                        letterSpacing: 2,
                      ),
                    ),
                    // Top predictions
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
                      ),
                    ],
                  ],
                ),
        ],
      ),
    );
  }
}
