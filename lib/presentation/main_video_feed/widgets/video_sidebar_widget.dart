import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoSidebarWidget extends StatelessWidget {
  final Map<String, dynamic> video;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onTip;

  const VideoSidebarWidget({
    Key? key,
    required this.video,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onTip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creator = video['user_profiles'] as Map<String, dynamic>?;

    return Positioned(
        right: 3.w,
        bottom: 15.h,
        child: Column(children: [
          // Creator avatar
          if (creator != null) ...[
            GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profileScreen,
                      arguments: creator['id']);
                },
                child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2)),
                    child: CustomImageWidget(
                        imageUrl: creator['avatar_url'] ?? '',
                        width: 12.w,
                        height: 12.w))),

            // Follow button
            SizedBox(height: 1.h),
            Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35), shape: BoxShape.circle),
                child: CustomIconWidget(
                    iconName: 'add', color: Colors.white, size: 4.w)),

            SizedBox(height: 4.h),
          ],

          // Like button
          _buildActionButton(
              icon: 'favorite', count: video['like_count'] ?? 0, onTap: onLike),

          SizedBox(height: 3.h),

          // Comment button
          _buildActionButton(
              icon: 'chat_bubble_outline',
              count: video['comment_count'] ?? 0,
              onTap: onComment),

          SizedBox(height: 3.h),

          // Share button
          _buildActionButton(
              icon: 'share', count: video['share_count'] ?? 0, onTap: onShare),

          SizedBox(height: 3.h),

          // Tip button
          _buildActionButton(
              icon: 'attach_money',
              count: video['tip_count'] ?? 0,
              onTap: onTip),
        ]));
  }

  Widget _buildActionButton({
    required String icon,
    required int count,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
        onTap: onTap,
        child: Column(children: [
          CustomIconWidget(iconName: icon, color: Colors.white, size: 7.w),
          if (count != 0) ...[
            SizedBox(height: 0.5.h),
            Text(count.toString(),
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500)),
          ],
        ]));
  }
}