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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withAlpha(204),
            backgroundColor.withAlpha(153),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main illustration with improved loading and error handling
              Hero(
                tag: 'onboarding_image_$imageUrl',
                child: Container(
                  width: 80.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(38),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                        spreadRadius: 2,
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
                      errorWidget: Container(
                        width: 80.w,
                        height: 35.h,
                        decoration: BoxDecoration(
                          color: backgroundColor.withAlpha(77),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: textColor.withAlpha(153),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 6.h),

              // Title with improved typography
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 24.sp,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ) ??
                    TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 24.sp,
                    ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 2.h),

              // Subtitle with better readability
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: textColor.withAlpha(217),
                        fontSize: 16.sp,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ) ??
                      TextStyle(
                        color: textColor.withAlpha(217),
                        fontSize: 16.sp,
                        height: 1.6,
                      ),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
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
