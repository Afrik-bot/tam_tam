import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Map<String, dynamic> userProfile;
  final bool isOwnProfile;
  final VoidCallback? onMessageTap;
  final VoidCallback? onTipTap;
  final VoidCallback? onCollaborateTap;
  final VoidCallback? onShareTap;

  const ActionButtonsWidget({
    Key? key,
    required this.userProfile,
    required this.isOwnProfile,
    this.onMessageTap,
    this.onTipTap,
    this.onCollaborateTap,
    this.onShareTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOwnProfile) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        children: [
          // Message Button
          Expanded(
            child: _buildActionButton(
              icon: 'message',
              label: userProfile["isVip"] as bool? ?? false
                  ? "DM (\$${userProfile["dmPrice"] ?? "5"})"
                  : "Message",
              onTap: onMessageTap,
              isPrimary: false,
            ),
          ),

          SizedBox(width: 3.w),

          // Tip Button
          Expanded(
            child: _buildActionButton(
              icon: 'monetization_on',
              label: "Tip",
              onTap: onTipTap,
              isPrimary: true,
            ),
          ),

          SizedBox(width: 3.w),

          // Collaborate Button
          Expanded(
            child: _buildActionButton(
              icon: 'group_work',
              label: "Collab",
              onTap: onCollaborateTap,
              isPrimary: false,
            ),
          ),

          SizedBox(width: 3.w),

          // Share Button
          GestureDetector(
            onTap: onShareTap,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isPrimary
                  ? AppTheme.lightTheme.colorScheme.onPrimary
                  : AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: isPrimary
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
