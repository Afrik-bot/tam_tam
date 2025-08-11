import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoBottomOverlayWidget extends StatefulWidget {
  final Map<String, dynamic> video;
  final VoidCallback? onUsernameClick;
  final VoidCallback? onSoundClick;

  const VideoBottomOverlayWidget({
    Key? key,
    required this.video,
    this.onUsernameClick,
    this.onSoundClick,
  }) : super(key: key);

  @override
  State<VideoBottomOverlayWidget> createState() =>
      _VideoBottomOverlayWidgetState();
}

class _VideoBottomOverlayWidgetState extends State<VideoBottomOverlayWidget> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final creator = widget.video['creator'] as Map<String, dynamic>? ?? {};
    final username = creator['username'] as String? ?? 'Unknown User';
    final description = widget.video['description'] as String? ?? '';
    final hashtags = (widget.video['hashtags'] as List?)?.cast<String>() ?? [];
    final sound = widget.video['sound'] as Map<String, dynamic>? ?? {};
    final soundName = sound['name'] as String? ?? 'Original Sound';
    final isLive = widget.video['isLive'] as bool? ?? false;
    final viewerCount = widget.video['viewerCount'] as int? ?? 0;

    return Positioned(
      left: 4.w,
      right: 20.w,
      bottom: 12.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live indicator
          if (isLive)
            Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'LIVE',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '${_formatViewerCount(viewerCount)} watching',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),

          // Username
          GestureDetector(
            onTap: widget.onUsernameClick,
            child: Text(
              '@$username',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Description and hashtags
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: RichText(
              maxLines: _isDescriptionExpanded ? null : 2,
              overflow: _isDescriptionExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
                children: [
                  if (description.isNotEmpty) ...[
                    TextSpan(text: description),
                    const TextSpan(text: ' '),
                  ],
                  ...hashtags.map((hashtag) => TextSpan(
                        text: '#$hashtag ',
                        style: TextStyle(
                          color: AppTheme.lightTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                  if (!_isDescriptionExpanded &&
                      (description.length > 50 || hashtags.isNotEmpty))
                    const TextSpan(
                      text: '... more',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 1.5.h),

          // Sound attribution
          GestureDetector(
            onTap: widget.onSoundClick,
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'music_note',
                  color: Colors.white,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    soundName,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 11.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatViewerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
