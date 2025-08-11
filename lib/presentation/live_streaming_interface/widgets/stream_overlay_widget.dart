import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StreamOverlayWidget extends StatelessWidget {
  final int viewerCount;
  final String streamDuration;
  final VoidCallback onClose;
  final bool isStreaming;

  const StreamOverlayWidget({
    super.key,
    required this.viewerCount,
    required this.streamDuration,
    required this.onClose,
    required this.isStreaming,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8.h,
      left: 4.w,
      right: 4.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStreamInfo(),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildStreamInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: isStreaming ? Colors.red : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'LIVE',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 3.w),
          CustomIconWidget(
            iconName: 'visibility',
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            viewerCount.toString(),
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            streamDuration,
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: 'close',
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
