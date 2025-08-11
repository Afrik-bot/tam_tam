import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MetricsCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String iconName;
  final Color iconColor;
  final bool showProgress;
  final double? progressValue;
  final Color? progressColor;

  const MetricsCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconName,
    required this.iconColor,
    this.showProgress = false,
    this.progressValue,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CustomIconWidget(
                iconName: iconName,
                color: iconColor,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          showProgress ? SizedBox(height: 2.h) : const SizedBox.shrink(),
          showProgress && progressValue != null
              ? LinearProgressIndicator(
                  value: progressValue! / 100,
                  backgroundColor: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? AppTheme.lightTheme.colorScheme.primary,
                  ),
                  minHeight: 4,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
