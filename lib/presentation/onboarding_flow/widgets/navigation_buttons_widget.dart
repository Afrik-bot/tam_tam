import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NavigationButtonsWidget extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final VoidCallback? onGetStarted;
  final bool isLastPage;

  const NavigationButtonsWidget({
    Key? key,
    this.onNext,
    this.onSkip,
    this.onGetStarted,
    required this.isLastPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      child: Column(
        children: [
          // Main action button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: isLastPage ? onGetStarted : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor:
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  if (!isLastPage) ...[
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'arrow_forward',
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (!isLastPage) ...[
            SizedBox(height: 2.h),

            // Skip button
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
              child: Text(
                'Skip',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
