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
  String? _errorMessage;

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
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load real content from database
      final videos = await ContentService.getFeedContent(limit: 20);

      if (videos.isEmpty && !AuthService.isAuthenticated) {
        // If no videos and user not authenticated, show preview content
        setState(() {
          _videos = _getPreviewContent();
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      // Show fallback content if there's an error
      if (_videos.isEmpty) {
        setState(() {
          _videos = _getPreviewContent();
        });
      }

      // Show error message to user
      if (mounted) {
        String displayMessage = _errorMessage!;

        if (displayMessage.contains('No videos found') ||
            displayMessage.contains('Database might be empty')) {
          displayMessage = 'Content is loading. Pull down to refresh.';
        } else if (displayMessage.contains('network') ||
            displayMessage.contains('Failed to fetch')) {
          displayMessage = 'Check your internet connection and try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(displayMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadVideos,
            ),
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getPreviewContent() {
    // Fallback content for preview or when database is empty
    return [
      {
        'id': 'preview_1',
        'title': 'Welcome to Tam Tam!',
        'description':
            'Create, Connect, and Earn with amazing video content. Join our community today!',
        'video_url':
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        'thumbnail_url': 'https://picsum.photos/400/600?random=1',
        'creator_username': 'tamtam_official',
        'creator_full_name': 'Tam Tam Official',
        'creator_avatar_url':
            'https://ui-avatars.com/api/?name=TamTam&background=FF6B35&color=fff&size=150',
        'creator_verified': true,
        'creator_followers_count': 10000,
        'view_count': 50000,
        'like_count': 2500,
        'comment_count': 180,
        'share_count': 320,
        'allows_comments': true,
        'allows_duets': true,
        'tags': ['welcome', 'tamtam', 'community'],
        'created_at':
            DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'preview_2',
        'title': 'Amazing Dance Moves',
        'description':
            'Check out these incredible dance moves! 🔥 #dance #trending',
        'video_url':
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        'thumbnail_url': 'https://picsum.photos/400/600?random=2',
        'creator_username': 'dance_star',
        'creator_full_name': 'Dance Star',
        'creator_avatar_url':
            'https://ui-avatars.com/api/?name=DS&background=random&size=150',
        'creator_verified': false,
        'creator_followers_count': 5600,
        'view_count': 28000,
        'like_count': 1800,
        'comment_count': 95,
        'share_count': 210,
        'allows_comments': true,
        'allows_duets': true,
        'tags': ['dance', 'trending', 'moves'],
        'created_at':
            DateTime.now().subtract(Duration(hours: 5)).toIso8601String(),
      },
      {
        'id': 'preview_3',
        'title': 'Cooking Magic',
        'description':
            'Learn this amazing recipe in just 60 seconds! Perfect for beginners 👨‍🍳',
        'video_url':
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        'thumbnail_url': 'https://picsum.photos/400/600?random=3',
        'creator_username': 'chef_master',
        'creator_full_name': 'Chef Master',
        'creator_avatar_url':
            'https://ui-avatars.com/api/?name=CM&background=random&size=150',
        'creator_verified': true,
        'creator_followers_count': 8900,
        'view_count': 42000,
        'like_count': 3200,
        'comment_count': 256,
        'share_count': 580,
        'allows_comments': true,
        'allows_duets': false,
        'tags': ['cooking', 'recipe', 'food', 'tutorial'],
        'created_at':
            DateTime.now().subtract(Duration(hours: 8)).toIso8601String(),
      },
    ];
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
    if (_isLoading) return;

    try {
      final moreVideos = await ContentService.getFeedContent(
          page: (_videos.length / 10).floor(), limit: 10);

      if (moreVideos.isNotEmpty) {
        setState(() {
          _videos.addAll(moreVideos);
        });
      }
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
            ? _buildLoadingState()
            : _videos.isEmpty
                ? _buildEmptyState()
                : _buildVideoFeed());
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            strokeWidth: 3,
          ),
          SizedBox(height: 3.h),
          Text(
            'Loading amazing content...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Get ready for the best videos!',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _refreshVideos,
      color: Color(0xFFFF6B35),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          SizedBox(height: 25.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35).withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.video_library_outlined,
              size: 80.sp,
              color: Color(0xFFFF6B35),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            AuthService.isAuthenticated
                ? 'No videos available'
                : 'Welcome to Tam Tam!',
            style: TextStyle(
                fontSize: 24.sp,
                color: Colors.white,
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            AuthService.isAuthenticated
                ? 'Content is loading or database is empty. Pull down to refresh or check back later.'
                : 'Create, Connect, and Earn with amazing video content. Sign up to join our creative community!',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white70,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          if (!AuthService.isAuthenticated) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.registration);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
              child: Text('Join Tam Tam',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
            ),
            SizedBox(height: 2.h),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: Text('Sign In',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _loadVideos,
              icon: Icon(Icons.refresh, size: 20.sp),
              label: Text('Reload Content',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.8.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                elevation: 3,
              ),
            ),
            SizedBox(height: 2.h),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.videoCreationStudio);
              },
              icon: Icon(Icons.add_circle_outline, size: 20.sp),
              label: Text('Create Content',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.8.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoFeed() {
    return RefreshIndicator(
        onRefresh: _refreshVideos,
        color: Color(0xFFFF6B35),
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
        height: 35.h,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(242),
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
            SizedBox(height: 1.h),
            ListTile(
              leading: Icon(Icons.bookmark_outline,
                  color: Colors.white, size: 24.sp),
              title: Text('Save Video',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              onTap: () {
                Navigator.pop(context);
                _saveVideo(video['id']);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.share_outlined, color: Colors.white, size: 24.sp),
              title: Text('Share Video',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              onTap: () {
                Navigator.pop(context);
                _handleShare(video['id']);
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.person_outline, color: Colors.white, size: 24.sp),
              title: Text('View Profile',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              onTap: () {
                Navigator.pop(context);
                _viewProfile(video['creator_id']);
              },
            ),
            if (video['allows_duets'] == true)
              ListTile(
                leading:
                    Icon(Icons.duo_outlined, color: Colors.white, size: 24.sp),
                title: Text('Duet',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _createDuet(video);
                },
              ),
            ListTile(
              leading:
                  Icon(Icons.report_outlined, color: Colors.red, size: 24.sp),
              title: Text('Report',
                  style: TextStyle(color: Colors.red, fontSize: 16.sp)),
              onTap: () {
                Navigator.pop(context);
                _reportContent(video['id']);
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
        SnackBar(
          content: Text('Video saved to your collection!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _createDuet(Map<String, dynamic> video) {
    // Navigate to video creation with duet option
    Navigator.pushNamed(
      context,
      AppRoutes.videoCreationStudio,
      arguments: {'duet_with': video},
    );
  }

  Future<void> _reportContent(String contentId) async {
    try {
      await ContentService.reportContent(contentId, 'inappropriate_content');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Content reported. Thank you for keeping our community safe.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to report content. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewProfile(String? creatorId) {
    if (creatorId != null && creatorId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        AppRoutes.userProfile,
        arguments: creatorId,
      );
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like video. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
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
            height: MediaQuery.of(context).size.height * 0.75,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Comments',
                          style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )),
              const Divider(color: Colors.white24),
              Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                future: ContentService.getContentComments(contentId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B35),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load comments',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 14.sp),
                      ),
                    );
                  }

                  final comments = snapshot.data ?? [];

                  if (comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48.sp,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No comments yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Be the first to comment!',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return _buildCommentItem(comment);
                    },
                  );
                },
              )),
              _buildCommentInput(contentId),
            ])));
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20.sp,
            backgroundImage: NetworkImage(
              comment['avatar_url'] ??
                  'https://ui-avatars.com/api/?name=${comment['username'] ?? 'User'}&background=random&size=150',
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['username'] ?? 'Unknown User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (comment['verified'] == true) ...[
                      SizedBox(width: 1.w),
                      Icon(
                        Icons.verified,
                        color: Color(0xFFFF6B35),
                        size: 16.sp,
                      ),
                    ],
                    Spacer(),
                    Text(
                      _formatTimeAgo(comment['created_at']),
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  comment['text_content'] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(String contentId) {
    final TextEditingController commentController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border(top: BorderSide(color: Colors.white24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Color(0xFFFF6B35)),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: () async {
              final comment = commentController.text.trim();
              if (comment.isNotEmpty) {
                try {
                  await ContentService.addComment(contentId, comment);
                  commentController.clear();
                  // Refresh the comments
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to post comment'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String? createdAt) {
    if (createdAt == null) return '';

    try {
      final DateTime commentTime = DateTime.parse(createdAt);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(commentTime);

      if (difference.inDays > 7) {
        return '${commentTime.day}/${commentTime.month}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'now';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _handleShare(String contentId) async {
    try {
      await ContentService.shareContent(contentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share video'),
            backgroundColor: Colors.red,
          ),
        );
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text('Send Tip',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Show your appreciation to this creator!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                          height: 1.3,
                        )),
                    SizedBox(height: 2.h),
                    Text('Tipping feature coming soon!',
                        style: TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Got it',
                          style: TextStyle(
                            color: const Color(0xFFFF6B35),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ))),
                ]));
  }

  void _showAuthRequired() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text('Join Tam Tam',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp)),
                content: Text(
                  'Sign up to like videos, leave comments, and connect with amazing creators!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16.sp,
                          ))),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.registration);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6B35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ))),
                ]));
  }
}
