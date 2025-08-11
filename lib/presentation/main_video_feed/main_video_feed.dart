import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/content_service.dart';
import './widgets/video_bottom_overlay_widget.dart';
import './widgets/video_player_widget.dart';
import './widgets/video_sidebar_widget.dart';

class MainVideoFeed extends StatefulWidget {
  const MainVideoFeed({super.key});

  @override
  State<MainVideoFeed> createState() => _MainVideoFeedState();
}

class _MainVideoFeedState extends State<MainVideoFeed>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadVideos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Pause videos when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Videos will be paused automatically by setting isActive to false
      setState(() {});
    }
  }

  Future<void> _loadVideos() async {
    try {
      setState(() => _isLoading = true);

      // Use real data instead of mock data
      final videos = await ContentService.getFeedContent(limit: 20);

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Failed to load videos: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _refreshVideos() async {
    await _loadVideos();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);

    // Load more videos when near the end
    if (index >= _videos.length - 3) {
      _loadMoreVideos();
    }
  }

  Future<void> _loadMoreVideos() async {
    try {
      final moreVideos = await ContentService.getFeedContent(
          page: (_videos.length / 10).floor(), limit: 10);

      setState(() {
        _videos.addAll(moreVideos);
      });
    } catch (e) {
      // Handle error silently for pagination
      print('Failed to load more videos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : _videos.isEmpty
                ? _buildEmptyState()
                : _buildVideoFeed());
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
        onRefresh: _refreshVideos,
        child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              SizedBox(height: 30.h),
              Icon(Icons.video_library_outlined,
                  size: 80.sp, color: Colors.white54),
              SizedBox(height: 2.h),
              Text(
                  AuthService.isAuthenticated
                      ? 'No videos available'
                      : 'Sign in to see personalized content',
                  style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center),
              SizedBox(height: 1.h),
              Text(
                  AuthService.isAuthenticated
                      ? 'Pull to refresh or check back later'
                      : 'Connect with creators and discover amazing content',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white54),
                  textAlign: TextAlign.center),
              if (!AuthService.isAuthenticated) ...[
                SizedBox(height: 4.h),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                    child: Text('Sign In',
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.w600))),
              ],
            ]));
  }

  Widget _buildVideoFeed() {
    return RefreshIndicator(
        onRefresh: _refreshVideos,
        child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _videos.length,
            itemBuilder: (context, index) {
              final video = _videos[index];

              return Stack(children: [
                // Video player with improved state management
                VideoPlayerWidget(
                  video: video,
                  isActive: index == _currentPage,
                  onDoubleTap: () => _handleLike(video['id'] ?? ''),
                  onLongPress: () => _showQuickActions(video),
                ),

                // Bottom overlay with video info
                VideoBottomOverlayWidget(video: video),

                // Right sidebar with actions
                VideoSidebarWidget(
                  video: video,
                  onLike: () => _handleLike(video['id'] ?? ''),
                  onComment: () => _handleComment(video['id'] ?? ''),
                  onShare: () => _handleShare(video['id'] ?? ''),
                  onTip: () =>
                      _handleTip(video['creator_id'] ?? '', video['id'] ?? ''),
                ),
              ]);
            }));
  }

  void _showQuickActions(Map<String, dynamic> video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 30.h,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(2.w),
              height: 0.5.h,
              width: 10.w,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: Icon(Icons.bookmark_outline, color: Colors.white),
              title: Text('Save Video', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _saveVideo(video['id']);
              },
            ),
            ListTile(
              leading: Icon(Icons.report_outlined, color: Colors.white),
              title: Text('Report', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _reportContent(video['id']);
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: Colors.white),
              title:
                  Text('View Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _viewProfile(video['creator_id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveVideo(String contentId) async {
    // Implementation for saving video
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video saved!')),
      );
    }
  }

  Future<void> _reportContent(String contentId) async {
    try {
      await ContentService.reportContent(contentId, 'inappropriate_content');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Content reported')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to report content')),
        );
      }
    }
  }

  void _viewProfile(String creatorId) {
    Navigator.pushNamed(
      context,
      AppRoutes.userProfile,
      arguments: creatorId,
    );
  }

  Future<void> _handleLike(String contentId) async {
    if (!AuthService.isAuthenticated) {
      _showAuthRequired();
      return;
    }

    try {
      await ContentService.likeContent(contentId);
      // Update local state optimistically
      setState(() {
        final index = _videos.indexWhere((v) => v['id'] == contentId);
        if (index != -1) {
          _videos[index]['like_count'] =
              (_videos[index]['like_count'] ?? 0) + 1;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to like video: $e')));
      }
    }
  }

  void _handleComment(String contentId) {
    if (!AuthService.isAuthenticated) {
      _showAuthRequired();
      return;
    }

    // Show comments bottom sheet
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(children: [
              Container(
                  margin: EdgeInsets.all(2.w),
                  height: 0.5.h,
                  width: 10.w,
                  decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(10))),
              Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Text('Comments',
                      style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600))),
              const Divider(color: Colors.white24),
              // Comments would be loaded here
              Expanded(
                  child: Center(
                      child: Text('Comments loading...',
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.white54)))),
            ])));
  }

  Future<void> _handleShare(String contentId) async {
    try {
      await ContentService.shareContent(contentId);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Video shared!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    }
  }

  void _handleTip(String creatorId, String contentId) {
    if (!AuthService.isAuthenticated) {
      _showAuthRequired();
      return;
    }

    // Show tip dialog
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Colors.black87,
                title: Text('Send Tip',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                content: Text('Tipping feature coming soon!',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                          style: TextStyle(color: const Color(0xFFFF6B35)))),
                ]));
  }

  void _showAuthRequired() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Colors.black87,
                title: Text('Sign In Required',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                content: Text('Please sign in to interact with content',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.white54))),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Text('Sign In',
                          style: TextStyle(color: const Color(0xFFFF6B35)))),
                ]));
  }
}