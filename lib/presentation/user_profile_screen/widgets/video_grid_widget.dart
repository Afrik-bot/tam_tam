import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  final bool isOwnProfile;
  final Function(Map<String, dynamic>) onVideoTap;
  final Function(Map<String, dynamic>) onVideoLongPress;

  const VideoGridWidget({
    Key? key,
    required this.videos,
    required this.isOwnProfile,
    required this.onVideoTap,
    required this.onVideoLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Container(
        height: 30.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'video_library',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              isOwnProfile ? "No videos yet" : "No videos to show",
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isOwnProfile)
              Container(
                margin: EdgeInsets.only(top: 1.h),
                child: Text(
                  "Start creating to see your videos here",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(6.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 0.7,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return GestureDetector(
          onTap: () => onVideoTap(video),
          onLongPress: () => onVideoLongPress(video),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.lightTheme.colorScheme.surface,
            ),
            child: Stack(
              children: [
                // Video Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: video["thumbnail"] as String? ??
                        "https://images.pexels.com/photos/3945313/pexels-photo-3945313.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Play Icon Overlay
                Center(
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'play_arrow',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),

                // Video Stats
                Positioned(
                  bottom: 1.w,
                  left: 1.w,
                  right: 1.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Play Count
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'play_circle_filled',
                              color: Colors.white,
                              size: 3.w,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                _formatNumber(video["playCount"] as int? ?? 0),
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Earnings (for own profile)
                        if (isOwnProfile && video["earnings"] != null)
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'monetization_on',
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                size: 3.w,
                              ),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Text(
                                  "\$${video["earnings"]}",
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.tertiary,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                // Video Duration
                Positioned(
                  top: 1.w,
                  right: 1.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 1.5.w, vertical: 0.5.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      video["duration"] as String? ?? "0:00",
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 8.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}K";
    }
    return number.toString();
  }
}
