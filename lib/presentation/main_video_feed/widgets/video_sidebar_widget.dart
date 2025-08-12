import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VideoSidebarWidget extends StatelessWidget {
  final Map<String, dynamic> video;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onTip;

  const VideoSidebarWidget({
    Key? key,
    required this.video,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onTip,
  }) : super(key: key);

  String _formatCount(dynamic count) {
    final int number = count is int ? count : (count as double?)?.toInt() ?? 0;

    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final creatorAvatarUrl = video['creator_avatar_url'] as String?;
    final isVerified = video['creator_verified'] as bool? ?? false;
    final likeCount = video['like_count'] ?? 0;
    final commentCount = video['comment_count'] ?? 0;
    final shareCount = video['share_count'] ?? 0;
    final tipCount = video['tip_count'] ?? 0;

    return Positioned(
      right: 3.w,
      bottom: 12.h,
      child: Column(
        children: [
          // Creator Avatar with Add Button
          _buildCreatorAvatar(creatorAvatarUrl, isVerified),
          SizedBox(height: 4.h),

          // Like Button
          _buildActionButton(
            icon: Icons.favorite,
            count: _formatCount(likeCount),
            onTap: onLike,
            isActive: false, // TODO: Check if user has liked
          ),
          SizedBox(height: 3.h),

          // Comment Button
          _buildActionButton(
            icon: Icons.chat_bubble,
            count: _formatCount(commentCount),
            onTap: onComment,
          ),
          SizedBox(height: 3.h),

          // Share Button
          _buildActionButton(
            icon: Icons.share,
            count: _formatCount(shareCount),
            onTap: onShare,
          ),
          SizedBox(height: 3.h),

          // Tip Button
          if (tipCount > 0 || true) // Show tip button always
            _buildActionButton(
              icon: Icons.monetization_on,
              count: tipCount > 0 ? _formatCount(tipCount) : 'Tip',
              onTap: onTip,
              iconColor: Colors.amber,
            ),

          SizedBox(height: 3.h),

          // More Actions Button
          _buildActionButton(
            icon: Icons.more_vert,
            count: '',
            onTap: () {
              // Handle more actions (duet, effects, etc.)
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorAvatar(String? avatarUrl, bool isVerified) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to creator profile
          },
          child: Container(
            width: 60.sp,
            height: 60.sp,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.sp),
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.sp),
              child: CachedNetworkImage(
                imageUrl: avatarUrl ??
                    'https://ui-avatars.com/api/?name=User&background=random&size=150',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: Colors.grey[600],
                    size: 30.sp,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: Colors.grey[600],
                    size: 30.sp,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Verified Badge
        if (isVerified)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                color: Color(0xFFFF6B35),
                size: 16.sp,
              ),
            ),
          ),

        // Add/Follow Button
        Positioned(
          bottom: -8,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                // Handle follow/unfollow
              },
              child: Container(
                width: 24.sp,
                height: 24.sp,
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String count,
    required VoidCallback onTap,
    bool isActive = false,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          children: [
            // Icon Container
            Container(
              width: 48.sp,
              height: 48.sp,
              decoration: BoxDecoration(
                color: isActive ? Color(0xFFFF6B35) : Colors.transparent,
                shape: BoxShape.circle,
                border: isActive
                    ? null
                    : Border.all(
                        color: Colors.white30,
                        width: 1,
                      ),
              ),
              child: Icon(
                icon,
                color: iconColor ?? (isActive ? Colors.white : Colors.white),
                size: 28.sp,
              ),
            ),

            // Count/Label
            if (count.isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Container(
                constraints: BoxConstraints(maxWidth: 60.sp),
                child: Text(
                  count,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
