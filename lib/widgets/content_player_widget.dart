import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentPlayerWidget extends StatefulWidget {
  final Map<String, dynamic> content;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onTip;
  final bool isLiked;

  const ContentPlayerWidget({
    Key? key,
    required this.content,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onTip,
    this.isLiked = false,
  }) : super(key: key);

  @override
  State<ContentPlayerWidget> createState() => _ContentPlayerWidgetState();
}

class _ContentPlayerWidgetState extends State<ContentPlayerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heartAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _animateHeart() {
    _heartController.forward().then((_) {
      _heartController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final creator = widget.content['user_profiles'] as Map<String, dynamic>?;

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Main Content Area
          _buildMainContent(),

          // Creator Info Overlay (Bottom Left)
          _buildCreatorInfo(creator),

          // Action Buttons (Bottom Right)
          _buildActionButtons(),

          // Top Gradient for Status Bar
          _buildTopGradient(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final contentType = widget.content['type'] as String? ?? 'video';

    if (contentType == 'image') {
      return _buildImageContent();
    } else if (contentType == 'video') {
      return _buildVideoContent();
    } else {
      return _buildTextContent();
    }
  }

  Widget _buildImageContent() {
    final imageUrl =
        widget.content['video_url'] ?? widget.content['thumbnail_url'];

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            )
          : Container(
              color: Colors.grey[900],
              child: const Center(
                child: Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
    );
  }

  Widget _buildVideoContent() {
    final thumbnailUrl = widget.content['thumbnail_url'];

    // For now, show thumbnail with play button
    // In a real app, you would integrate a video player
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          thumbnailUrl != null
              ? CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.video_library,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(
                      Icons.video_library,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),

          // Play button overlay
          Center(
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(128),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 8.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    final title = widget.content['title'] as String? ?? '';
    final description = widget.content['description'] as String? ?? '';

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade900,
            Colors.blue.shade900,
            Colors.teal.shade900,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
              ],
              if (description.isNotEmpty)
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.white.withAlpha(230),
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorInfo(Map<String, dynamic>? creator) {
    return Positioned(
      bottom: 15.h,
      left: 4.w,
      right: 20.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator info
          Row(
            children: [
              CircleAvatar(
                radius: 2.5.h,
                backgroundImage: creator?['avatar_url'] != null
                    ? CachedNetworkImageProvider(creator!['avatar_url'])
                    : null,
                backgroundColor: Colors.grey[700],
                child: creator?['avatar_url'] == null
                    ? Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 3.h,
                      )
                    : null,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          creator?['username'] ?? 'Unknown User',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (creator?['verified'] == true) ...[
                          SizedBox(width: 1.w),
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 3.w,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      creator?['full_name'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.white.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Content title/description
          if (widget.content['title'] != null) ...[
            Text(
              widget.content['title'],
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
          ],

          if (widget.content['description'] != null) ...[
            Text(
              widget.content['description'],
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: Colors.white.withAlpha(204),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
          ],

          // Tags
          if (widget.content['tags'] != null) ...[
            Wrap(
              children: (widget.content['tags'] as List<dynamic>)
                  .take(3)
                  .map((tag) => Container(
                        margin: EdgeInsets.only(right: 2.w, bottom: 1.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(77),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        child: Text(
                          '#$tag',
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            color: Colors.white,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 15.h,
      right: 4.w,
      child: Column(
        children: [
          // Like button
          _buildActionButton(
            icon: widget.isLiked ? Icons.favorite : Icons.favorite_border,
            label: _formatCount(widget.content['like_count'] ?? 0),
            color: widget.isLiked ? Colors.red : Colors.white,
            onTap: () {
              if (widget.isLiked) {
                _animateHeart();
              }
              widget.onLike?.call();
            },
          ),

          SizedBox(height: 3.h),

          // Comment button
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label: _formatCount(widget.content['comment_count'] ?? 0),
            onTap: widget.onComment,
          ),

          SizedBox(height: 3.h),

          // Share button
          _buildActionButton(
            icon: Icons.share_outlined,
            label: _formatCount(widget.content['share_count'] ?? 0),
            onTap: widget.onShare,
          ),

          SizedBox(height: 3.h),

          // Tip button
          _buildActionButton(
            icon: Icons.monetization_on_outlined,
            label: _formatCount(widget.content['tip_count'] ?? 0),
            color: Colors.yellow[700],
            onTap: widget.onTip,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _heartAnimation,
        builder: (context, child) {
          final scale = icon == Icons.favorite && widget.isLiked
              ? _heartAnimation.value
              : 1.0;

          return Transform.scale(
            scale: scale,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color ?? Colors.white,
                    size: 6.w,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopGradient() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 12.h,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha(128),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}
