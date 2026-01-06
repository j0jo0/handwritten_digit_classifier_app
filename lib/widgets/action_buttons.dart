import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget that displays the action buttons
class ActionButtons extends StatelessWidget {
  final VoidCallback? onClear;
  final VoidCallback? onAnalyze;

  const ActionButtons({
    super.key,
    required this.onClear,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Clear Button
        Expanded(
          child: Container(
            // Style the button
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
                onTap: onClear,
                borderRadius: BorderRadius.circular(16.r),
                child: Center(
                  // Content of the button
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
            // Style the button
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
                onTap: onAnalyze,
                borderRadius: BorderRadius.circular(16.r),
                child: Center(
                  // Content of the button
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
    );
  }
}
