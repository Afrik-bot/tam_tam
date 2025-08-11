import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContentPerformanceWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const ContentPerformanceWidget({
    super.key,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  @override
  State<ContentPerformanceWidget> createState() =>
      _ContentPerformanceWidgetState();
}

class _ContentPerformanceWidgetState extends State<ContentPerformanceWidget> {
  final List<Map<String, dynamic>> topVideos = [
    {
      "id": 1,
      "title": "AI Dance Challenge #TechVibes",
      "thumbnail":
          "https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg",
      "views": 2450000,
      "likes": 189000,
      "shares": 45000,
      "comments": 12500,
      "earnings": 890.50,
      "duration": "0:45",
      "uploadDate": "2025-08-09"
    },
    {
      "id": 2,
      "title": "Crypto Trading Tips for Beginners",
      "thumbnail":
          "https://images.pexels.com/photos/730547/pexels-photo-730547.jpeg",
      "views": 1890000,
      "likes": 156000,
      "shares": 32000,
      "comments": 8900,
      "earnings": 675.25,
      "duration": "1:23",
      "uploadDate": "2025-08-08"
    },
    {
      "id": 3,
      "title": "Behind the Scenes: Studio Setup",
      "thumbnail":
          "https://images.pexels.com/photos/1181406/pexels-photo-1181406.jpeg",
      "views": 1230000,
      "likes": 98000,
      "shares": 18000,
      "comments": 5600,
      "earnings": 445.75,
      "duration": "2:15",
      "uploadDate": "2025-08-07"
    },
    {
      "id": 4,
      "title": "Collab with @TechGuru - NFT Drop",
      "thumbnail":
          "https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg",
      "views": 980000,
      "likes": 87000,
      "shares": 25000,
      "comments": 4200,
      "earnings": 1250.00,
      "duration": "1:05",
      "uploadDate": "2025-08-06"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
        children: [
          GestureDetector(
            onTap: widget.onToggleExpanded,
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Content Performance',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: widget.isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          widget.isExpanded
              ? Column(
                  children: [
                    ...topVideos.map((video) => _buildVideoItem(video)),
                    SizedBox(height: 2.h),
                  ],
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Performing Videos',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${topVideos.length} videos',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> video) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: video["thumbnail"] as String,
                  width: 20.w,
                  height: 12.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 1.w,
                right: 1.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    video["duration"] as String,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video["title"] as String,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'visibility',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _formatNumber(video["views"] as int),
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 3.w),
                    CustomIconWidget(
                      iconName: 'favorite',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _formatNumber(video["likes"] as int),
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Earned: \$${(video["earnings"] as double).toStringAsFixed(2)}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
