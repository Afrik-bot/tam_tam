import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsSheetWidget extends StatelessWidget {
  final Map<String, dynamic> video;
  final VoidCallback? onSave;
  final VoidCallback? onReport;
  final VoidCallback? onNotInterested;
  final VoidCallback? onClose;

  const QuickActionsSheetWidget({
    Key? key,
    required this.video,
    this.onSave,
    this.onReport,
    this.onNotInterested,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creator = video['creator'] as Map<String, dynamic>? ?? {};
    final username = creator['username'] as String? ?? 'Unknown User';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Video info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: (video['thumbnail'] as String?) ?? '',
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@$username',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        (video['description'] as String?) ?? '',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: Colors.grey.withValues(alpha: 0.2),
            height: 1,
          ),

          // Action buttons
          _buildActionItem(
            icon: 'bookmark_border',
            title: 'Save video',
            subtitle: 'Add this to your saved videos',
            onTap: () {
              onSave?.call();
              onClose?.call();
            },
          ),

          _buildActionItem(
            icon: 'flag_outlined',
            title: 'Report',
            subtitle: 'Report this video for inappropriate content',
            onTap: () {
              onReport?.call();
              onClose?.call();
            },
          ),

          _buildActionItem(
            icon: 'not_interested',
            title: 'Not interested',
            subtitle: 'See fewer videos like this',
            onTap: () {
              onNotInterested?.call();
              onClose?.call();
            },
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
