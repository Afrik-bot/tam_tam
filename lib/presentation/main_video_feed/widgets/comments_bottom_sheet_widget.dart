import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CommentsBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> video;
  final VoidCallback? onClose;

  const CommentsBottomSheetWidget({
    Key? key,
    required this.video,
    this.onClose,
  }) : super(key: key);

  @override
  State<CommentsBottomSheetWidget> createState() =>
      _CommentsBottomSheetWidgetState();
}

class _CommentsBottomSheetWidgetState extends State<CommentsBottomSheetWidget> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock comments data
  final List<Map<String, dynamic>> _comments = [
    {
      "id": 1,
      "user": {
        "username": "sarah_music",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isVerified": true,
      },
      "text": "This beat is absolutely fire! 🔥 Can't stop listening to it",
      "timestamp": "2h",
      "likes": 234,
      "isLiked": false,
      "replies": 12,
    },
    {
      "id": 2,
      "user": {
        "username": "mike_beats",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isVerified": false,
      },
      "text": "Yo this is sick! What's the name of this track?",
      "timestamp": "1h",
      "likes": 89,
      "isLiked": true,
      "replies": 5,
    },
    {
      "id": 3,
      "user": {
        "username": "dance_queen",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isVerified": false,
      },
      "text":
          "Already learned the choreography! Tutorial coming soon on my page 💃",
      "timestamp": "45m",
      "likes": 156,
      "isLiked": false,
      "replies": 8,
    },
    {
      "id": 4,
      "user": {
        "username": "crypto_king",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isVerified": true,
      },
      "text": "Just tipped 50 TAM tokens! Keep creating amazing content 🚀",
      "timestamp": "30m",
      "likes": 67,
      "isLiked": false,
      "replies": 3,
    },
    {
      "id": 5,
      "user": {
        "username": "global_vibes",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "isVerified": false,
      },
      "text": "This song needs to be on Spotify ASAP! Anyone know the artist?",
      "timestamp": "15m",
      "likes": 23,
      "isLiked": true,
      "replies": 1,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentCount = widget.video['commentCount'] as int? ?? 0;

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$commentCount comments',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: Colors.grey.withValues(alpha: 0.2),
            height: 1,
          ),

          // Comments list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return _buildCommentItem(comment);
              },
            ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl:
                            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
                        width: 8.w,
                        height: 8.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                      ),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: _postComment,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'send',
                        color: Colors.white,
                        size: 5.w,
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

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final user = comment['user'] as Map<String, dynamic>;
    final username = user['username'] as String;
    final avatar = user['avatar'] as String;
    final isVerified = user['isVerified'] as bool;
    final text = comment['text'] as String;
    final timestamp = comment['timestamp'] as String;
    final likes = comment['likes'] as int;
    final isLiked = comment['isLiked'] as bool;
    final replies = comment['replies'] as int;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: avatar,
                width: 8.w,
                height: 8.w,
                fit: BoxFit.cover,
              ),
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
                      username,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isVerified) ...[
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: 'verified',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 3.w,
                      ),
                    ],
                    SizedBox(width: 2.w),
                    Text(
                      timestamp,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  text,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleCommentLike(comment['id']),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: isLiked ? 'favorite' : 'favorite_border',
                            color: isLiked ? Colors.red : Colors.grey,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            likes.toString(),
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              fontSize: 10.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    if (replies > 0)
                      GestureDetector(
                        onTap: () => _showReplies(comment['id']),
                        child: Text(
                          'View $replies ${replies == 1 ? 'reply' : 'replies'}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontSize: 10.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _postComment() {
    if (_commentController.text.trim().isNotEmpty) {
      // Add comment logic here
      _commentController.clear();
    }
  }

  void _toggleCommentLike(int commentId) {
    setState(() {
      final commentIndex = _comments.indexWhere((c) => c['id'] == commentId);
      if (commentIndex != -1) {
        final comment = _comments[commentIndex];
        final isLiked = comment['isLiked'] as bool;
        comment['isLiked'] = !isLiked;
        comment['likes'] = (comment['likes'] as int) + (isLiked ? -1 : 1);
      }
    });
  }

  void _showReplies(int commentId) {
    // Show replies logic here
  }
}
