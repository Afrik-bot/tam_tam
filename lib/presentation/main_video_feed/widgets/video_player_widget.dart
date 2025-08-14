import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';

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

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showPlayButton = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      _handleActiveStateChange();
    }

    if (widget.video['video_url'] != oldWidget.video['video_url']) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    // Dispose previous controller
    await _controller?.dispose();

    setState(() {
      _isInitialized = false;
      _hasError = false;
      _errorMessage = null;
      _isBuffering = true;
    });

    final videoUrl = widget.video['video_url'] as String?;

    if (videoUrl == null || videoUrl.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Video URL not available';
        _isBuffering = false;
      });
      return;
    }

    try {
      // Create new controller with better error handling
      if (videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Invalid video URL format';
          _isBuffering = false;
        });
        return;
      }

      // Add listener for buffering state
      _controller?.addListener(_videoListener);

      // Initialize the controller with timeout
      await _controller?.initialize().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Video initialization timeout');
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isBuffering = false;
          _hasError = false;
        });

        // Set looping
        _controller?.setLooping(true);

        // Auto-play if active
        if (widget.isActive) {
          _controller?.play();
        }
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video';
          _isBuffering = false;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      final bool isBuffering = _controller!.value.isBuffering;
      if (_isBuffering != isBuffering) {
        setState(() {
          _isBuffering = isBuffering;
        });
      }
    }
  }

  void _handleActiveStateChange() {
    if (!_isInitialized || _controller == null) return;

    if (widget.isActive) {
      _controller?.play();
      setState(() {
        _showPlayButton = false;
      });
    } else {
      _controller?.pause();
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized || _controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller?.pause();
      setState(() {
        _showPlayButton = true;
      });
    } else {
      _controller?.play();
      setState(() {
        _showPlayButton = false;
      });
    }
  }

  Widget _buildVideoControls() {
    if (!_showPlayButton && !_isBuffering) return Container();

    return Container(
      color: Colors.black26,
      child: Center(
        child: AnimatedOpacity(
          opacity: _showPlayButton || _isBuffering ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: _isBuffering
              ? CircularProgressIndicator(
                  color: Color(0xFFFF6B35),
                  strokeWidth: 3,
                )
              : GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final thumbnailUrl = widget.video['thumbnail_url'] as String?;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Show thumbnail as background if available
          if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 40.sp,
                  ),
                ),
              ),
            )
          else
            Container(color: Colors.grey[900]),

          // Error overlay
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    color: Color(0xFFFF6B35),
                    size: 48.sp,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Video unavailable',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 1.h),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 2.h),
                  ElevatedButton.icon(
                    onPressed: _initializeVideo,
                    icon: Icon(Icons.refresh, size: 16.sp),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    final thumbnailUrl = widget.video['thumbnail_url'] as String?;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Show thumbnail while loading if available
          if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                ),
              ),
            )
          else
            Container(color: Colors.grey[900]),

          // Loading overlay
          Container(
            color: Colors.black38,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFF6B35),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Loading video...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: _hasError
            ? _buildErrorWidget()
            : !_isInitialized
                ? _buildLoadingWidget()
                : Stack(
                    children: [
                      // Video player with fixed aspect ratio handling
                      Positioned.fill(
                        child: Center(
                          child: _controller!.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _controller!.value.aspectRatio > 0
                                          ? _controller!.value.aspectRatio
                                          : 16 / 9, // Fallback aspect ratio
                                  child: VideoPlayer(_controller!),
                                )
                              : Container(
                                  color: Colors.black,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFF6B35),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Controls overlay
                      Positioned.fill(
                        child: _buildVideoControls(),
                      ),
                      // Simple progress bar at bottom (without VideoProgressIndicator)
                      if (_isInitialized &&
                          widget.isActive &&
                          _controller != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            child: ValueListenableBuilder<VideoPlayerValue>(
                              valueListenable: _controller!,
                              builder: (context, value, child) {
                                if (!value.isInitialized) {
                                  return Container(color: Colors.white10);
                                }
                                final progress = value.position.inMilliseconds /
                                    value.duration.inMilliseconds;
                                return LinearProgressIndicator(
                                  value: progress.isNaN ? 0.0 : progress,
                                  backgroundColor: Colors.white10,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF6B35),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
