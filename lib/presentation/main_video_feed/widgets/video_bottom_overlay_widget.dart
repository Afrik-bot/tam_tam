import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class VideoBottomOverlayWidget extends StatelessWidget {
  final Map<String, dynamic> video;

  const VideoBottomOverlayWidget({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final creatorUsername = video['creator_username'] as String? ?? 'Unknown';
    final creatorFullName = video['creator_full_name'] as String?;
    final title = video['title'] as String? ?? '';
    final description = video['description'] as String? ?? '';
    final tags = video['tags'] as List<dynamic>? ?? [];
    final location = video['location'] as String?;
    final isVerified = video['creator_verified'] as bool? ?? false;
    final viewCount = video['view_count'] ?? 0;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withAlpha(204),
              Colors.black.withAlpha(102),
              Colors.transparent,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        padding: EdgeInsets.fromLTRB(4.w, 6.h, 20.w, 3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Creator Info
            _buildCreatorInfo(
                creatorUsername, creatorFullName, isVerified, viewCount),

            SizedBox(height: 1.h),

            // Video Title
            if (title.isNotEmpty) _buildTitle(title),

            // Video Description
            if (description.isNotEmpty) ...[
              SizedBox(height: 0.8.h),
              _buildDescription(description),
            ],

            // Tags
            if (tags.isNotEmpty) ...[
              SizedBox(height: 1.h),
              _buildTags(tags),
            ],

            // Location
            if (location != null && location.isNotEmpty) ...[
              SizedBox(height: 1.h),
              _buildLocation(location),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorInfo(
      String username, String? fullName, bool isVerified, int viewCount) {
    return Row(
      children: [
        // Username and verification
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to creator profile
                },
                child: Text(
                  '@$username',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isVerified) ...[
                SizedBox(width: 1.w),
                Icon(
                  Icons.verified,
                  color: Color(0xFFFF6B35),
                  size: 18.sp,
                ),
              ],
              if (fullName != null && fullName != username) ...[
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    '• $fullName',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),

        // View Count
        if (viewCount > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatViewCount(viewCount),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return GestureDetector(
      onTap: () {
        // Show full title in dialog or expand
      },
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDescription(String description) {
    return GestureDetector(
      onTap: () {
        // Show full description in dialog or expand
      },
      child: Text(
        description,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTags(List<dynamic> tags) {
    // Limit to first 3-4 tags to avoid overflow
    final displayTags = tags.take(4).toList();

    return Wrap(
      spacing: 2.w,
      runSpacing: 0.5.h,
      children: displayTags.map((tag) {
        final tagString = tag.toString().toLowerCase();
        return GestureDetector(
          onTap: () {
            // Search for videos with this tag
          },
          child: Text(
            '#$tagString',
            style: TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocation(String location) {
    return GestureDetector(
      onTap: () {
        // Show location details or search
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: Colors.white70,
            size: 16.sp,
          ),
          SizedBox(width: 1.w),
          Flexible(
            child: Text(
              location,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatViewCount(int viewCount) {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$viewCount views';
    }
  }
}
