import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color backgroundColor;
  final Color textColor;

  const OnboardingPageWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            backgroundColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main illustration
              Container(
                width: 80.w,
                height: 35.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: 80.w,
                    height: 35.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 6.h),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 24.sp,
                ),
              ),

              SizedBox(height: 2.h),

              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 16.sp,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
