import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StreamControlsWidget extends StatelessWidget {
  final VoidCallback onCameraFlip;
  final VoidCallback onBeautyFilter;
  final VoidCallback onScreenShare;
  final VoidCallback onEndStream;
  final bool isScreenSharing;
  final bool isBeautyFilterOn;

  const StreamControlsWidget({
    super.key,
    required this.onCameraFlip,
    required this.onBeautyFilter,
    required this.onScreenShare,
    required this.onEndStream,
    required this.isScreenSharing,
    required this.isBeautyFilterOn,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12.h,
      right: 4.w,
      child: Column(
        children: [
          _buildControlButton(
            icon: 'flip_camera_ios',
            onTap: onCameraFlip,
            isActive: false,
          ),
          SizedBox(height: 2.h),
          _buildControlButton(
            icon: 'face',
            onTap: onBeautyFilter,
            isActive: isBeautyFilterOn,
          ),
          SizedBox(height: 2.h),
          _buildControlButton(
            icon: 'screen_share',
            onTap: onScreenShare,
            isActive: isScreenSharing,
          ),
          SizedBox(height: 3.h),
          _buildEndStreamButton(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildEndStreamButton() {
    return GestureDetector(
      onTap: onEndStream,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'stop',
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
