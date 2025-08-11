import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../core/app_export.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Map<String, dynamic> video;
  final bool isActive;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const VideoPlayerWidget({
    Key? key,
    required this.video,
    required this.isActive,
    this.onDoubleTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _showLikeAnimation = false;

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _likeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _likeAnimationController, curve: Curves.elasticOut));

    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle active state changes
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _playVideo();
      } else {
        _pauseVideo();
      }
    }

    // Handle video source changes
    if (widget.video['id'] != oldWidget.video['id']) {
      _disposeVideo();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final videoUrl = widget.video['video_url'] as String?;

    if (videoUrl == null || videoUrl.isEmpty) {
      setState(() {
        _hasError = true;
        _isVideoInitialized = false;
      });
      return;
    }

    try {
      // Create video controller
      if (videoUrl.startsWith('http')) {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        // Handle storage URLs from Supabase
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      }

      await _videoController!.initialize();

      // Set video to loop
      await _videoController!.setLooping(true);

      // Set volume
      await _videoController!.setVolume(1.0);

      setState(() {
        _isVideoInitialized = true;
        _hasError = false;
      });

      // Auto-play if this video is active
      if (widget.isActive) {
        _playVideo();
      }
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _hasError = true;
        _isVideoInitialized = false;
      });
    }
  }

  Future<void> _playVideo() async {
    if (_videoController != null && _isVideoInitialized && !_hasError) {
      try {
        await _videoController!.play();
        setState(() => _isPlaying = true);
      } catch (e) {
        print('Error playing video: $e');
      }
    }
  }

  Future<void> _pauseVideo() async {
    if (_videoController != null && _isVideoInitialized) {
      try {
        await _videoController!.pause();
        setState(() => _isPlaying = false);
      } catch (e) {
        print('Error pausing video: $e');
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    setState(() {
      _isVideoInitialized = false;
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _disposeVideo();
    super.dispose();
  }

  void _triggerLikeAnimation() {
    setState(() {
      _showLikeAnimation = true;
    });
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reset();
      setState(() {
        _showLikeAnimation = false;
      });
    });
    widget.onDoubleTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onDoubleTap: _triggerLikeAnimation,
        onLongPress: widget.onLongPress,
        onTap: () {
          if (_isVideoInitialized) {
            _togglePlayPause();
          }
        },
        child: Container(
            width: 100.w,
            height: 100.h,
            color: Colors.black,
            child: Stack(fit: StackFit.expand, children: [
              // Video or thumbnail
              if (_isVideoInitialized && !_hasError && _videoController != null)
                Center(
                    child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!)))
              else if (_hasError)
                // Show thumbnail as fallback
                _buildThumbnailFallback()
              else
                // Loading state
                _buildLoadingState(),

              // Play/Pause overlay when not playing or loading
              if (_isVideoInitialized && !_isPlaying && !_hasError)
                Container(
                    color: Colors.black.withValues(alpha: 0.2),
                    child: Center(
                        child: CustomIconWidget(
                            iconName: 'play_arrow',
                            color: Colors.white,
                            size: 20.w))),

              // Loading overlay
              if (!_isVideoInitialized && !_hasError)
                Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0))),

              // Error overlay
              if (_hasError)
                Positioned(
                    bottom: 20.h,
                    left: 4.w,
                    right: 4.w,
                    child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.warning, color: Colors.orange, size: 4.w),
                          SizedBox(width: 2.w),
                          Expanded(
                              child: Text(
                                  'Video unavailable - showing thumbnail',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12.sp))),
                        ]))),

              // Like animation overlay
              if (_showLikeAnimation)
                Center(
                    child: AnimatedBuilder(
                        animation: _likeAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                              scale: _likeAnimation.value,
                              child: Opacity(
                                  opacity: 1.0 - _likeAnimation.value,
                                  child: CustomIconWidget(
                                      iconName: 'favorite',
                                      color: Colors.red,
                                      size: 25.w)));
                        })),

              // Video quality indicator
              Positioned(
                  top: 8.h,
                  left: 4.w,
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                          _isVideoInitialized && !_hasError
                              ? 'HD'
                              : _hasError
                                  ? 'Error'
                                  : 'Loading...',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                                  color:
                                      _hasError ? Colors.orange : Colors.white,
                                  fontSize: 10.sp)))),
            ])));
  }

  Widget _buildThumbnailFallback() {
    return CustomImageWidget(
        imageUrl: (widget.video['thumbnail_url'] as String?) ?? '',
        width: 100.w,
        height: 100.h,
        fit: BoxFit.cover);
  }

  Widget _buildLoadingState() {
    return CustomImageWidget(
        imageUrl: (widget.video['thumbnail_url'] as String?) ?? '',
        width: 100.w,
        height: 100.h,
        fit: BoxFit.cover);
  }
}
