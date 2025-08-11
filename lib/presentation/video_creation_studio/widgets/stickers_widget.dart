import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StickersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onStickerSelected;
  final List<Map<String, dynamic>> selectedStickers;

  const StickersWidget({
    Key? key,
    required this.onStickerSelected,
    required this.selectedStickers,
  }) : super(key: key);

  @override
  State<StickersWidget> createState() => _StickersWidgetState();
}

class _StickersWidgetState extends State<StickersWidget> {
  String _selectedCategory = "Trending";
  final List<String> _categories = [
    "Trending",
    "Memes",
    "Emojis",
    "Location",
    "Interactive",
    "Custom"
  ];

  final List<Map<String, dynamic>> _trendingStickers = [
    {
      "id": "fire_emoji",
      "name": "Fire",
      "category": "Trending",
      "type": "emoji",
      "emoji": "🔥",
      "thumbnail":
          "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "heart_eyes",
      "name": "Heart Eyes",
      "category": "Trending",
      "type": "emoji",
      "emoji": "😍",
      "thumbnail":
          "https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "laughing",
      "name": "Laughing",
      "category": "Trending",
      "type": "emoji",
      "emoji": "😂",
      "thumbnail":
          "https://images.pexels.com/photos/1540406/pexels-photo-1540406.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "money_face",
      "name": "Money Face",
      "category": "Trending",
      "type": "emoji",
      "emoji": "🤑",
      "thumbnail":
          "https://images.pexels.com/photos/1699161/pexels-photo-1699161.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
  ];

  final List<Map<String, dynamic>> _memeStickers = [
    {
      "id": "stonks",
      "name": "Stonks",
      "category": "Memes",
      "type": "image",
      "thumbnail":
          "https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "this_is_fine",
      "name": "This is Fine",
      "category": "Memes",
      "type": "image",
      "thumbnail":
          "https://images.pexels.com/photos/2681319/pexels-photo-2681319.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "drake_pointing",
      "name": "Drake Pointing",
      "category": "Memes",
      "type": "image",
      "thumbnail":
          "https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "distracted_boyfriend",
      "name": "Distracted Boyfriend",
      "category": "Memes",
      "type": "image",
      "thumbnail":
          "https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
  ];

  final List<Map<String, dynamic>> _emojiStickers = [
    {
      "id": "thumbs_up",
      "name": "Thumbs Up",
      "category": "Emojis",
      "type": "emoji",
      "emoji": "👍",
    },
    {
      "id": "clap",
      "name": "Clap",
      "category": "Emojis",
      "type": "emoji",
      "emoji": "👏",
    },
    {
      "id": "peace",
      "name": "Peace",
      "category": "Emojis",
      "type": "emoji",
      "emoji": "✌️",
    },
    {
      "id": "rocket",
      "name": "Rocket",
      "category": "Emojis",
      "type": "emoji",
      "emoji": "🚀",
    },
    {
      "id": "star",
      "name": "Star",
      "category": "Emojis",
      "type": "emoji",
      "emoji": "⭐",
    },
    {
      "id": "crown",
      "name": "Crown",
      "category": "Emojis",
      "type": "emoji",
      "emoji": "👑",
    },
  ];

  final List<Map<String, dynamic>> _locationStickers = [
    {
      "id": "location_pin",
      "name": "Location Pin",
      "category": "Location",
      "type": "location",
      "icon": "location_on",
    },
    {
      "id": "city_tag",
      "name": "City Tag",
      "category": "Location",
      "type": "location",
      "icon": "location_city",
    },
    {
      "id": "map_marker",
      "name": "Map Marker",
      "category": "Location",
      "type": "location",
      "icon": "place",
    },
  ];

  final List<Map<String, dynamic>> _interactiveStickers = [
    {
      "id": "poll_sticker",
      "name": "Poll",
      "category": "Interactive",
      "type": "interactive",
      "icon": "poll",
      "description": "Add a poll to your video",
    },
    {
      "id": "question_sticker",
      "name": "Question",
      "category": "Interactive",
      "type": "interactive",
      "icon": "help",
      "description": "Ask viewers a question",
    },
    {
      "id": "countdown_sticker",
      "name": "Countdown",
      "category": "Interactive",
      "type": "interactive",
      "icon": "timer",
      "description": "Add a countdown timer",
    },
    {
      "id": "donation_sticker",
      "name": "Donation",
      "category": "Interactive",
      "type": "interactive",
      "icon": "volunteer_activism",
      "description": "Enable donations",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      child: Column(
        children: [
          // Category tabs
          Container(
            height: 6.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 3.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.onPrimary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // Stickers grid
          Expanded(
            child: _buildStickersGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildStickersGrid() {
    List<Map<String, dynamic>> stickers = [];

    switch (_selectedCategory) {
      case "Trending":
        stickers = _trendingStickers;
        break;
      case "Memes":
        stickers = _memeStickers;
        break;
      case "Emojis":
        stickers = _emojiStickers;
        break;
      case "Location":
        stickers = _locationStickers;
        break;
      case "Interactive":
        stickers = _interactiveStickers;
        break;
      case "Custom":
        stickers =
            []; // Custom stickers would be loaded from user's saved stickers
        break;
    }

    if (stickers.isEmpty && _selectedCategory == "Custom") {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'add_photo_alternate',
              size: 15.w,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            Text(
              'No custom stickers yet',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Upload your own stickers to use them in videos',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                // Handle custom sticker upload
              },
              icon: CustomIconWidget(
                iconName: 'upload',
                size: 4.w,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
              label: Text('Upload Sticker'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.9,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        final isSelected =
            widget.selectedStickers.any((s) => s["id"] == sticker["id"]);

        return GestureDetector(
          onTap: () {
            widget.onStickerSelected(sticker);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      color: AppTheme.lightTheme.colorScheme.surface,
                    ),
                    child: _buildStickerContent(sticker),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12)),
                    ),
                    child: Center(
                      child: Text(
                        sticker["name"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickerContent(Map<String, dynamic> sticker) {
    final type = sticker["type"] as String;

    switch (type) {
      case "emoji":
        return Center(
          child: Text(
            sticker["emoji"] as String,
            style: TextStyle(fontSize: 12.w),
          ),
        );

      case "image":
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: CustomImageWidget(
            imageUrl: sticker["thumbnail"] as String,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        );

      case "location":
      case "interactive":
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: sticker["icon"] as String,
                size: 8.w,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              if (sticker["description"] != null) ...[
                SizedBox(height: 1.h),
                Text(
                  sticker["description"] as String,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    fontSize: 8.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );

      default:
        return Center(
          child: CustomIconWidget(
            iconName: 'image',
            size: 8.w,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        );
    }
  }
}
