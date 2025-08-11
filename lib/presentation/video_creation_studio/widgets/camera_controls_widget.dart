import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraControlsWidget extends StatefulWidget {
  final CameraController? cameraController;
  final Function() onFlipCamera;
  final Function() onToggleFlash;
  final Function() onSetTimer;
  final Function() onStartCollaboration;
  final bool isFlashOn;
  final int timerSeconds;
  final bool isCollaborationMode;

  const CameraControlsWidget({
    Key? key,
    required this.cameraController,
    required this.onFlipCamera,
    required this.onToggleFlash,
    required this.onSetTimer,
    required this.onStartCollaboration,
    required this.isFlashOn,
    required this.timerSeconds,
    required this.isCollaborationMode,
  }) : super(key: key);

  @override
  State<CameraControlsWidget> createState() => _CameraControlsWidgetState();
}

class _CameraControlsWidgetState extends State<CameraControlsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Top controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildControlButton(
                icon: 'flip_camera_ios',
                onTap: widget.onFlipCamera,
                tooltip: 'Flip Camera',
              ),
              if (!kIsWeb) // Flash not supported on web
                _buildControlButton(
                  icon: widget.isFlashOn ? 'flash_on' : 'flash_off',
                  onTap: widget.onToggleFlash,
                  tooltip: 'Toggle Flash',
                  isActive: widget.isFlashOn,
                ),
              _buildControlButton(
                icon: 'timer',
                onTap: widget.onSetTimer,
                tooltip: 'Set Timer',
                badge: widget.timerSeconds > 0
                    ? widget.timerSeconds.toString()
                    : null,
              ),
              _buildControlButton(
                icon: 'people',
                onTap: widget.onStartCollaboration,
                tooltip: 'Multi-Creator Mode',
                isActive: widget.isCollaborationMode,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Camera viewfinder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: widget.cameraController != null &&
                        widget.cameraController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: widget.cameraController!.value.aspectRatio,
                        child: CameraPreview(widget.cameraController!),
                      )
                    : Container(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'videocam',
                                size: 12.w,
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Initializing Camera...',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isActive = false,
    String? badge,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 12.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2)
                : AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
              width: isActive ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: CustomIconWidget(
                  iconName: icon,
                  size: 6.w,
                  color: isActive
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 0.5.h,
                  right: 1.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onError,
                        fontSize: 8.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
