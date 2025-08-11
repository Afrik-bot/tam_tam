import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EffectsGridWidget extends StatefulWidget {
  final Function(String) onEffectSelected;
  final String? selectedEffect;

  const EffectsGridWidget({
    Key? key,
    required this.onEffectSelected,
    this.selectedEffect,
  }) : super(key: key);

  @override
  State<EffectsGridWidget> createState() => _EffectsGridWidgetState();
}

class _EffectsGridWidgetState extends State<EffectsGridWidget> {
  final List<Map<String, dynamic>> _effects = [
    {
      "id": "beauty",
      "name": "Beauty",
      "icon": "face_retouching_natural",
      "category": "AR Filters",
      "thumbnail":
          "https://images.pexels.com/photos/3992656/pexels-photo-3992656.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "vintage",
      "name": "Vintage",
      "icon": "filter_vintage",
      "category": "Filters",
      "thumbnail":
          "https://images.pexels.com/photos/1323550/pexels-photo-1323550.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "neon",
      "name": "Neon Glow",
      "icon": "highlight",
      "category": "AR Filters",
      "thumbnail":
          "https://images.pexels.com/photos/2681319/pexels-photo-2681319.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "blur",
      "name": "Background Blur",
      "icon": "blur_on",
      "category": "Effects",
      "thumbnail":
          "https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "sparkle",
      "name": "Sparkle",
      "icon": "auto_awesome",
      "category": "AR Filters",
      "thumbnail":
          "https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "rainbow",
      "name": "Rainbow",
      "icon": "palette",
      "category": "Filters",
      "thumbnail":
          "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "glitch",
      "name": "Glitch",
      "icon": "electrical_services",
      "category": "Effects",
      "thumbnail":
          "https://images.pexels.com/photos/2047905/pexels-photo-2047905.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
    {
      "id": "cartoon",
      "name": "Cartoon",
      "icon": "face",
      "category": "AR Filters",
      "thumbnail":
          "https://images.pexels.com/photos/1040881/pexels-photo-1040881.jpeg?auto=compress&cs=tinysrgb&w=300",
    },
  ];

  final List<Map<String, dynamic>> _transitions = [
    {
      "id": "fade",
      "name": "Fade",
      "icon": "fade",
      "category": "Transitions",
    },
    {
      "id": "slide",
      "name": "Slide",
      "icon": "swipe",
      "category": "Transitions",
    },
    {
      "id": "zoom",
      "name": "Zoom",
      "icon": "zoom_in",
      "category": "Transitions",
    },
    {
      "id": "spin",
      "name": "Spin",
      "icon": "rotate_right",
      "category": "Transitions",
    },
  ];

  final List<Map<String, dynamic>> _autoCutSuggestions = [
    {
      "id": "beat_sync",
      "name": "Beat Sync",
      "icon": "music_note",
      "category": "Auto-Cut",
      "description": "Sync cuts to music beats",
    },
    {
      "id": "face_detection",
      "name": "Face Focus",
      "icon": "face_retouching_natural",
      "category": "Auto-Cut",
      "description": "Cut when faces appear",
    },
    {
      "id": "motion_cut",
      "name": "Motion Cut",
      "icon": "directions_run",
      "category": "Auto-Cut",
      "description": "Cut on motion changes",
    },
    {
      "id": "color_pop",
      "name": "Color Pop",
      "icon": "colorize",
      "category": "Auto-Cut",
      "description": "Cut on color changes",
    },
  ];

  String _selectedCategory = "AR Filters";
  final List<String> _categories = [
    "AR Filters",
    "Filters",
    "Effects",
    "Transitions",
    "Auto-Cut"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
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
          // Effects grid
          Expanded(
            child: _buildEffectsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectsGrid() {
    List<Map<String, dynamic>> items = [];

    switch (_selectedCategory) {
      case "AR Filters":
      case "Filters":
      case "Effects":
        items = _effects
            .where(
                (effect) => (effect["category"] as String) == _selectedCategory)
            .toList();
        break;
      case "Transitions":
        items = _transitions;
        break;
      case "Auto-Cut":
        items = _autoCutSuggestions;
        break;
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = widget.selectedEffect == item["id"];

        return GestureDetector(
          onTap: () {
            widget.onEffectSelected(item["id"] as String);
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
                    child: item["thumbnail"] != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: CustomImageWidget(
                              imageUrl: item["thumbnail"] as String,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: CustomIconWidget(
                              iconName: item["icon"] as String,
                              size: 8.w,
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
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
                        item["name"] as String,
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
}
