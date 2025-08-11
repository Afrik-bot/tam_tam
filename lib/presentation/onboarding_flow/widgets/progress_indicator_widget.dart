import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const ProgressIndicatorWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        children: List.generate(totalPages, (index) {
          final isActive = index == currentPage;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
          );
        }),
      ),
    );
  }
}
