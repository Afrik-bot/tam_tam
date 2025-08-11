import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class VideoTimelineWidget extends StatefulWidget {
  final double videoDuration;
  final double currentPosition;
  final Function(double) onPositionChanged;

  const VideoTimelineWidget({
    Key? key,
    required this.videoDuration,
    required this.currentPosition,
    required this.onPositionChanged,
  }) : super(key: key);

  @override
  State<VideoTimelineWidget> createState() => _VideoTimelineWidgetState();
}

class _VideoTimelineWidgetState extends State<VideoTimelineWidget> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(widget.currentPosition),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _formatDuration(widget.videoDuration),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                });
              },
              onPanUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final progress =
                    (localPosition.dx / box.size.width).clamp(0.0, 1.0);
                widget.onPositionChanged(progress * widget.videoDuration);
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                });
              },
              child: Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.h),
                ),
                child: Stack(
                  children: [
                    // Progress bar
                    FractionallySizedBox(
                      widthFactor: widget.videoDuration > 0
                          ? (widget.currentPosition / widget.videoDuration)
                              .clamp(0.0, 1.0)
                          : 0.0,
                      child: Container(
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2.h),
                        ),
                      ),
                    ),
                    // Scrubber handle
                    Positioned(
                      left: widget.videoDuration > 0
                          ? ((widget.currentPosition / widget.videoDuration) *
                                  (100.w - 8.w - 3.w))
                              .clamp(0.0, 100.w - 8.w - 3.w)
                          : 0.0,
                      top: 0.5.h,
                      child: Container(
                        width: 3.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.lightTheme.colorScheme.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final int minutes = (seconds / 60).floor();
    final int remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
