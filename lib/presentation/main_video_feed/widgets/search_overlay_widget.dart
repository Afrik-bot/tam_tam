import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchOverlayWidget extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(String)? onSearch;

  const SearchOverlayWidget({
    Key? key,
    this.onClose,
    this.onSearch,
  }) : super(key: key);

  @override
  State<SearchOverlayWidget> createState() => _SearchOverlayWidgetState();
}

class _SearchOverlayWidgetState extends State<SearchOverlayWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Mock trending challenges data
  final List<Map<String, dynamic>> _trendingChallenges = [
    {
      "id": 1,
      "name": "DanceChallenge2024",
      "description": "Show off your best dance moves",
      "participantCount": 2500000,
      "hashtag": "#DanceChallenge2024",
      "thumbnail":
          "https://images.pexels.com/photos/3621104/pexels-photo-3621104.jpeg",
    },
    {
      "id": 2,
      "name": "CryptoVibes",
      "description": "Share your crypto success stories",
      "participantCount": 890000,
      "hashtag": "#CryptoVibes",
      "thumbnail":
          "https://images.pexels.com/photos/7567443/pexels-photo-7567443.jpeg",
    },
    {
      "id": 3,
      "name": "AfrobeatsFusion",
      "description": "Mix Afrobeats with your style",
      "participantCount": 1200000,
      "hashtag": "#AfrobeatsFusion",
      "thumbnail":
          "https://images.pexels.com/photos/3621104/pexels-photo-3621104.jpeg",
    },
    {
      "id": 4,
      "name": "TechTalk",
      "description": "Share your tech knowledge",
      "participantCount": 650000,
      "hashtag": "#TechTalk",
      "thumbnail":
          "https://images.pexels.com/photos/3861969/pexels-photo-3861969.jpeg",
    },
  ];

  final List<String> _recentSearches = [
    "dance tutorial",
    "crypto tips",
    "afrobeats remix",
    "live streaming",
    "tam token",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100.h),
          child: Container(
            width: 100.w,
            height: 100.h,
            color: AppTheme.lightTheme.colorScheme.surface,
            child: SafeArea(
              child: Column(
                children: [
                  // Search header
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _closeSearch,
                          child: CustomIconWidget(
                            iconName: 'arrow_back',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 6.w,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search videos, users, sounds...',
                              hintStyle: AppTheme
                                  .lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.withValues(alpha: 0.1),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.5.h,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                      child: CustomIconWidget(
                                        iconName: 'clear',
                                        color: Colors.grey,
                                        size: 5.w,
                                      ),
                                    )
                                  : null,
                            ),
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontSize: 14.sp,
                            ),
                            onChanged: (value) {
                              setState(() {});
                              widget.onSearch?.call(value);
                            },
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty) {
                                widget.onSearch?.call(value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recent searches
                          if (_searchController.text.isEmpty &&
                              _recentSearches.isNotEmpty) ...[
                            Text(
                              'Recent searches',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            ..._recentSearches.map(
                                (search) => _buildRecentSearchItem(search)),
                            SizedBox(height: 3.h),
                          ],

                          // Trending challenges
                          Text(
                            'Trending challenges',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          ..._trendingChallenges.map((challenge) =>
                              _buildTrendingChallengeItem(challenge)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return GestureDetector(
      onTap: () {
        _searchController.text = search;
        widget.onSearch?.call(search);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'history',
              color: Colors.grey,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                search,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _removeRecentSearch(search),
              child: CustomIconWidget(
                iconName: 'close',
                color: Colors.grey,
                size: 4.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingChallengeItem(Map<String, dynamic> challenge) {
    final name = challenge['name'] as String;
    final description = challenge['description'] as String;
    final participantCount = challenge['participantCount'] as int;
    final hashtag = challenge['hashtag'] as String;
    final thumbnail = challenge['thumbnail'] as String;

    return GestureDetector(
      onTap: () => _selectChallenge(challenge),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: thumbnail,
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hashtag,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${_formatCount(participantCount)} videos',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'trending_up',
              color: AppTheme.lightTheme.primaryColor,
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  void _closeSearch() {
    _animationController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _selectChallenge(Map<String, dynamic> challenge) {
    final hashtag = challenge['hashtag'] as String;
    _searchController.text = hashtag;
    widget.onSearch?.call(hashtag);
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
